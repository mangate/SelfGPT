#!/bin/bash

echo ==========================STARTING==========================
echo $SELFGPT_AZURE
echo ============================================================

if [[ -z $SELFGPT_AZURE ]]; then
    mkdir -p /root/.config/ngrok

    cp /SelfGPT/user/config/ngrok.yml /root/.config/ngrok/ngrok.yml
    sleep 3
    python3 src/selfgpt.py & ngrok http 5000 && fg
else
    mkdir -p user/config
    mkdir -p user/data
    python3 src/selfgpt.py
fi
