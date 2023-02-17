import os
import yaml

AZURE = {
  'connectionString': '',
  'container': '',
  'blob': '',
}

cfgFile = "../user/config/config.yaml"

if os.path.isfile(cfgFile):
  # Open the yaml config file and load the variables
  with open("../user/config/config.yaml", 'r') as stream:
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

if 'AZURE_FREE_PLAN_ID' in os.environ:
  AZURE_FREE_PLAN_ID = os.environ['AZURE_FREE_PLAN_ID']

bicepFile = "main.bicep"

with open(bicepFile) as f:
    newText = f.read() \
      .replace('@CONFIG__OPENAI_KEY@', OPENAI_KEY) \
      .replace('@CONFIG__AZURE__CONNECTIONSTRING@', AZURE['connectionString']) \
      .replace('@CONFIG__AZURE__CONTAINERNAME@', AZURE['container']) \
      .replace('@CONFIG__AZURE__BLOBNAME@', AZURE['blob']) \
      .replace('@AZURE_FREE_PLAN_ID@', AZURE_FREE_PLAN_ID)

with open(bicepFile, "w") as f:
    f.write(newText)
