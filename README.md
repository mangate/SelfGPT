# SelfGPT

This is the documentation for the SelfGPT WhatsApp bot. 

This bot allows you to contact GPT3 directly from WhatsApp.
This bot also allows you to save your own personal data and later search and retrieve it using GPT3 to generate a response. In the `examples` folder you can see several examples of how to use this bot so you don't have to remember anything ever again.

## Current Features

The bot can be used in two ways:
- **No-Command**: This is the default mode. The bot will respond to any message you send it through the GPT3 regular completion API.
- **Commands**: This mode is activated by sending the bot a message starting with the command character. The default command character is `/`. 
  - Currently supported commands:
    - **`/h`**: Show a help message that lists all the commands
    - **`/s <message>`**: Save the message to the database
    - **`/q <question>`**: Ask a question about the database and get a response from GPT3
    - **`/f <message>`**: Find a relatead messages in the database

## Future Features

- [ ]  Add a way to delete messages from the database.
- [ ]  Add a way to edit messages in the database.
- [ ]  Receive PDF/Word files and parse them into the database.
- [ ]  Receive audio messages, transcribe them and parse them into the database.

## How to use selfGPT
1. Clone or download the code from the repository.
   
2. Install the requirements using `pip install -r requirements.txt`
   
3. Set and account on [OpenAI](https://beta.openai.com/) and get your API key.

4. Add the API key to the `config.yaml` file.

5. Choose the path for your database file and add it to the `config.yaml` file as well.

5. **Twilio:**
   - Set an account on [Twilio](https://www.twilio.com/). 
   - Go to Twilio's [whatsapp website](https://www.twilio.com/whatsapp) and sign up.
   - Connect Twilio with WhatsApp (see [here](https://www.pragnakalp.com/create-whatsapp-bot-with-twilio-using-python-tutorial-with-examples/) for a tutorial).
   - Save the contact details given by Twilio.
   - Send message to the number given by Twilio as instructed in the tutorial.
  
6.  **NGROK**
    - Download and install [NGROK](https://ngrok.com/download).
    - Open the terminal and run `ngrok http 5000` (5000 is the default port used by Flask).
    - From that Ngrok links, copy the HTTPS link URL
    - Go to back to Twilio's sand box for whatsapp and add the URL given by NGROK with the suffix */wasms*  to the box marked `WHEN A MESSAGE COMES IN` (see [here](https://www.pragnakalp.com/create-whatsapp-bot-with-twilio-using-python-tutorial-with-examples/) for a tutorial) and press save.
  
That's it! You can now use the bot. Please note that the bot will only work if the terminal is open and running the code. Also the twilio sandbox disconnects after 72 hours so you will have to reconnect it after that. You might also have to get a new URL from NGROK and edit the Twilio sandbox again.

## How to contribute

This is an open source project and contributions are welcome. If you want to contribute, you can do so by forking the repository and making a pull request. If you have any questions or suggestions, you can open an issue or contact me directly.

## License

This project is licensed under the AGPL-3.0 License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

Huge credit for Pragnakalp for making this great tutorial on how to create a WhatsApp bot using Twilio and Flask. I used his tutorial as a base for this project. You can find the tutorial [here](https://www.pragnakalp.com/create-whatsapp-bot-with-twilio-using-python-tutorial-with-examples/).
