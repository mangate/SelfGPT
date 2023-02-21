import os
from datetime import datetime
import yaml

import openai
from openai.embeddings_utils import get_embedding, cosine_similarity
import numpy as np
from flask import Flask, request
from twilio.twiml.messaging_response import MessagingResponse

import file_dbaccess
import azure_blob_dbaccess

AZURE = {}

if os.path.isfile("user/config/config.yaml"):
  # Open the yaml config file and load the variables
  with open("user/config/config.yaml", 'r') as stream:
      config = yaml.safe_load(stream)
      OPENAI_KEY = config['OPENAI_KEY']
      AZURE = config['AZURE']
      DEPLOYMENT = config['DEPLOYMENT']

if 'CONFIG__OPENAI_KEY' in os.environ:
  OPENAI_KEY = os.environ['CONFIG__OPENAI_KEY']

if 'CONFIG__AZURE__CONNECTIONSTRING' in os.environ:
  AZURE['connectionString'] = os.environ['CONFIG__AZURE__CONNECTIONSTRING']

if 'CONFIG__AZURE__CONTAINERNAME' in os.environ:
  AZURE['container'] = os.environ['CONFIG__AZURE__CONTAINERNAME']

if 'CONFIG__AZURE__BLOBNAME' in os.environ:
  AZURE['blob'] = os.environ['CONFIG__AZURE__BLOBNAME']

if 'CONFIG__DEPLOYMENT' in os.environ:
  DEPLOYMENT = os.environ['CONFIG__DEPLOYMENT']

config_ok = True

if OPENAI_KEY == "<Your OpenAI API key>":
    print("Please add your OpenAI API key to the user/config/config.yaml file")
    config_ok = False

if not config_ok:
    exit()

print("\nOPENAI_KEY--> ", "\"" + OPENAI_KEY[0:2] + " ... " + OPENAI_KEY[-3:] + "\"\n")

if DEPLOYMENT == "local":
  print("Using local file database")
  db = file_dbaccess.LocalFileDbAccess("user/data/database.csv")
elif DEPLOYMENT == "azure":
  print("Using Azure Blob database")
  db = azure_blob_dbaccess.AzureBlobDbAccess({
    "CONNECTIONSTRING": AZURE['connectionString'],
    "CONTAINERNAME": AZURE['container'],
    "BLOBNAME": AZURE['blob'],
  })

EMBEDDING_MODEL = 'text-embedding-ada-002'
COMPLETIONS_MODEL = "text-davinci-003"
QUESTION_COMPLETIONS_API_PARAMS = {
    # We use temperature of 0.0 because it gives the most predictable, factual answer.
    "temperature": 0.0,
    "max_tokens": 200,
    "model": COMPLETIONS_MODEL,
}

REGULAR_COMPLETIONS_API_PARAMS = {
    "temperature": 0.5,
    "max_tokens": 500,
    "model": COMPLETIONS_MODEL,
}

app = Flask(__name__)
 
@app.route("/wa")
def wa_hello():
    return "Hello, what can I do for you!"
 
@app.route("/wasms", methods=['POST'])
def wa_sms_reply():
    """Respond to incoming calls with a simple text message."""
    # Fetch the message
    
    msg = request.form.get('Body').lower() # Reading the message from the whatsapp
    # Get the message time
    now = datetime.now()
    dt_string = now.strftime("%d/%m/%Y %H:%M:%S")
    
    # Load the database
    df = db.get()

    print("msg-->",msg) # Printing the message on the console, for debugging purpose
    resp = MessagingResponse()
    reply=resp.message()
    
    # Create reply
    # ========================================
    # Help menu
    if msg.startswith("/h"):
        reply.body("Commands:\n\n/q [question] - Ask a question\n/s [message] - Save a message\n/f [message] - Find related messages\n/h - Show this help menu")

    # Question answering
    elif msg.startswith("/q "):
        # Get the question
        question = msg.split("/q ")[1]
        # Construct the prompt
        prompt = construct_prompt(question, df, top_n=3)
        # Get the answer
        response = openai.Completion.create(prompt=prompt, **QUESTION_COMPLETIONS_API_PARAMS)
        reply.body(response["choices"][0]["text"])
    
    # Save the message
    elif msg.startswith("/s "):
        data_to_save = msg.split("/s ")[1]
        # Save the massage to the database
        text_embedding = get_embedding(data_to_save, engine='text-embedding-ada-002')
        df = df.append({"time":dt_string,"message":data_to_save, "ada_search": text_embedding},ignore_index=True)
        db.save(df)
        reply.body("Message saved successfully!")

    # Find related messages
    elif msg.startswith("/f "):
        query = msg.split("/f ")[1]
        most_similar = return_most_similiar(query, df, top_n=3)
        msg_reply = ''
        for i in range(len(most_similar)):
            msg_reply += most_similar.iloc[i]['time'] + ': ' + most_similar.iloc[i]['message'] + '\n'
        reply.body(msg_reply)

    # Placeholder for other commands
    elif msg.startswith("/"):
        reply.body("Sorry, I don't understand the command")

    # Get a regular completion
    else:
        # Just get a regular completion from the model
        COMPLETIONS_API_PARAMS = {
            # We use temperature of 0.0 because it gives the most predictable, factual answer.
            "temperature": 0.0,
            "max_tokens": 200,
            "model": COMPLETIONS_MODEL,
        }
        response = openai.Completion.create(prompt=msg, **REGULAR_COMPLETIONS_API_PARAMS)
        print (response)
        reply.body(response["choices"][0]["text"])
        
    return str(resp)

def construct_prompt(question, df, top_n=3):
    # Get the context
    context = generate_context(question, df, top_n)
    header =  header = """Answer the question in details, based only on the provided context and nothing else, and if the answer is not contained within the text below, say "I don't know.", do not invent or deduce!\n\nContext:\n"""
    return header + "".join(context) + "Q: " + question + "\n A:"

def generate_context(question, df, top_n=3):
    most_similiar = return_most_similiar(question, df, top_n)
    # Get the top 3 most similar messages
    top_messages = most_similiar["message"].values
    # Concatenate the top 3 messages into a single string
    context = '\n '.join(top_messages)
    return context

def return_most_similiar(question, df, top_n=3):
    # Get the embedding for the question
    question_embedding = get_embedding(question, engine='text-embedding-ada-002')
    # Get the embedding for the messages in the database
    df["ada_search"] = df["ada_search"].apply(eval).apply(np.array)
    # Get the similarity between the question and the messages in the database
    df['similarity'] = df.ada_search.apply(lambda x: cosine_similarity(x, question_embedding))
    # Get the index of the top 3 most similar message
    most_similiar = df.sort_values('similarity', ascending=False).head(top_n)
    return most_similiar

if __name__ == "__main__":	

    openai.api_key = OPENAI_KEY
    # Check if the database exists if not create it
    db.ensureExists()

    HOST = "0.0.0.0" if DEPLOYMENT=="azure" else "127.0.0.1"
    app.run(debug=True, host=HOST)
