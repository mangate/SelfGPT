#!/bin/bash
mkdir -p /root/.config/ngrok

cp /SelfGPT/source/config/ngrok.yml /root/.config/ngrok/ngrok.yml

sleep 3
python3 selfgpt.py & ngrok http 5000 && fg
