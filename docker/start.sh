#!/bin/bash

echo ==========================STARTING==========================
echo $SELFGPT_AZURE
echo ============================================================

mkdir -p /root/.cache/whisper
cp /SelfGPT/base.pt /root/.cache/whisper/base.pt

if [[ -z $SELFGPT_AZURE ]]; then
    mkdir -p /root/.config/ngrok

    cp /SelfGPT/user/config/ngrok.yml /root/.config/ngrok/ngrok.yml
    ngrok http 5000 >/dev/null &
    sleep 3
    WEBHOOK_URL="$(curl -s http://localhost:4040/api/tunnels | jq -r ".tunnels[0].public_url")"
    echo NGROK TUNNEL: $WEBHOOK_URL
    python3 src/selfgpt.py
else
    mkdir -p user/config
    mkdir -p user/data
    python3 src/selfgpt.py
fi
