# SelfGPT

This is the documentation for the SelfGPT WhatsApp bot. 

This bot allows you to contact GPT3 directly from WhatsApp.
This bot also allows you to save your own personal data and later search and retrieve it using GPT3 to generate a response. In the `examples` folder you can see several examples of how to use this bot so you don't have to remember anything ever again.

**Note:** While the code in its current state is very useful I would highly appreciate any contributions that would make it more "production-ready".

## Current Features

The bot can be used in two ways:
- **No-Command**: This is the default mode. The bot will respond to any message you send it through the GPT3 regular completion API.
- **Commands**: This mode is activated by sending the bot a message starting with the command character. The default command character is `/`. 
  - Currently supported commands:
    - **`/h`**: Show a help message that lists all the commands
    - **`/s <message>`**: Save the message to the database
    - **`/q <question>`**: Ask a question about the database and get a response from GPT3
    - **`/f <message>`**: Find related messages in the database

## Future Features

- [ ]  Add a way to delete messages from the database.
- [ ]  Add a way to edit messages in the database.
- [ ]  Receive PDF/Word files and parse them into the database.
- [ ]  Receive audio messages, transcribe them (using OpenAI Whisper or something similiar) and parse them into the database.
- [ ]  Add ability to upload photos, embedd them with OpenAI CLIP and enable searching them with natural language.

## How to use selfGPT
1. Clone or download the code from the repository.

2. Copy the files `user/config/config.yaml.example` and `user/config/ngrok.yml.example` to the same location but without the `.example` extension. Those files (without the `.example` extension) are ignored by git and you may safely put your secrets in them.

3. Set an account on [OpenAI](https://beta.openai.com/) and get your API key.

4. Add the API key to the `user\config\config.yaml` file.

5. If you are using _Docker_ skip to the [next section](#running-selfgpt-using-docker)

6. Install the requirements using `pip install -r requirements/requirements.txt` (you might need to run it with the `--user` flag depending on your setup)

7. The database will be saved into the `user\data` folder.

8. **Twilio:**
   - Set an account on [Twilio](https://www.twilio.com/). 
   - Go to Twilio's [whatsapp website](https://www.twilio.com/whatsapp) and sign up.
   - Connect Twilio with WhatsApp (see [here](https://www.pragnakalp.com/create-whatsapp-bot-with-twilio-using-python-tutorial-with-examples/) for a tutorial).
   - Save the contact details given by Twilio.
   - Send message to the number given by Twilio as instructed in the tutorial.
  
9.  **NGROK**
    - Download and install [NGROK](https://ngrok.com/download).
    - Make sure you configure NGROK with your auth token (visit https://dashboard.ngrok.com/get-started/your-authtoken)
    - Open the terminal and run `ngrok http 5000` (5000 is the default port used by Flask).
    - From that Ngrok links, copy the HTTPS link URL
    - Go to back to Twilio's sand box for whatsapp and add the URL given by NGROK with the suffix */wasms*  to the box marked `WHEN A MESSAGE COMES IN` (see [here](https://www.pragnakalp.com/create-whatsapp-bot-with-twilio-using-python-tutorial-with-examples/) for a tutorial) and press save.
  
That's it! You can now use the bot by running `selfgpt.py`. Notice that tha bot runs only as long as the program runs.

## Running SelfGPT using Docker

1. Add your NGROK auth token to `user/config/ngrok.yml` (`yml` not `yaml`)
   (visit https://dashboard.ngrok.com/get-started/your-authtoken)

2. You need to set up your _Twilio_ account similar to step 8 in the previous section.

3. Run `build-docker.cmd`

4. Run `run-docker.cmd`

5. Finally, copy the NGROK forwarding address into your Twilio configuration.

## Storing the Database in Azure

If you plan to host your bot on the cloud, or if you don't want to store the database locally on your machine, you can configure *SelfGPT* to use *Azure Storage*.

1. Create an *Azure Storage* account and grab its connection string from the *Access keys* blade.

2. Edit your `config.yaml`
   1. Set `DEPLOYMENT: azure`
   2. Set the `AZURE:` section like this:
```
AZURE:
  connectionString: <your connection string>
  container: selfgpt
  blob: theblob
```

3. The container and blob names are arbitrary, and you may change them if you want.

## Deploy to Microsoft Azure

1. First make sure it runs on your machine, either directly, or via Docker. The reason for this is that the deployment scripts use the configuration as set in the `user/config` directory.

2. Also make sure you have set up your storage account by following the instructions in the [previous section](#storing-the-database-in-azure).

3. Install the *Azure CLI* tools, instructions [here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) and verify they work properly by running `az account list` and making sure it completes without error and outputs the correct information.

4. Enter the `azure` folder, and run `generate-azure-template.cmd` - it will generate an *ARM* (Azure Resource Manager) *JSON* template which you can deploy either interactively using the [*Azure Portal*](https://portal.azure.com/), or by using the `az` *Azure CLI* command set.

5. If you have already created a resource group to hold the deployment, you may deploy using *Azure CLI* by runing `az deployment group create --resource-group <<resource group name>> --template-file main.json`. You will be prompted to choose the app name (the name must be unique across *Azure*).

6. If you want to create a new resource group, you can do so using the [*Azure Portal*](https://portal.azure.com/) or using the script `create-resource-group.cmd` (to get a list of locations you may use the script `list-locations.cmd`).

7. The docker image used for this deployment is hosted on [*Docker Hub*](https://hub.docker.com/layers/paviad/selfgpt/v5/images/sha256-537a4b80793bf11c03c014e805434283609e32ed99f3747998069a5c99204355?context=repo) and tagged `paviad/selfgpt:v5` and it's a snapshot of this repository as it was on February 17th 2023. You may and probably should change the image tag to refer to the latest image (right now it is `paviad/selfgpt:latest`) or if you've hosted your own image, you may of course use that instead.

8. Once the app is deployed, you can enter its address in the _Twilio_ incoming message hook (remember to suffix it with `/wasms`). The address is `https://<<app name>>.azurewebsites.net/wasms`.

**NOTE**: If you are using a free app service plan (as is the default in the repo at the moment), note that it might take a while for the app to "warm up" so be patient (might take up to 3 minutes, or maybe more). The way to deal with that is to send a `/h` command to the bot and if it doesn't respond, wait 3 minutes and send another `/h` - only if it responds then you may send other commands to it.

## Known issues

- The Twilio account disconnects every 72 hours: Reconnecting is easy. Just send the same message you sent on step 8 that connected you in the first place.
- The Ngrok changes URL: Sometime the bot would stop responding. This can be caused by the Ngrok changing the URL. In this case you have to repeat step 9.

## How to contribute

This is an open source project and contributions are welcome. If you want to contribute, you can do so by forking the repository and making a pull request. If you have any questions or suggestions, you can open an issue or contact me directly.

## License

This project is licensed under the AGPL-3.0 License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

Huge credit for Pragnakalp for making this great tutorial on how to create a WhatsApp bot using Twilio and Flask. I used his tutorial as a base for this project. You can find the tutorial [here](https://www.pragnakalp.com/create-whatsapp-bot-with-twilio-using-python-tutorial-with-examples/).
