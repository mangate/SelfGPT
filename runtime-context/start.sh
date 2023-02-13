#!/bin/bash
if [[ -f "config-secret.yaml" ]]; then
  echo Found config-secret.yaml - using it
  cp config-secret.yaml config.yaml
fi
if [[ -f "ngrok-secret.yml" ]]; then
  echo Found ngrok-secret.yml - using it
  cp ngrok-secret.yml ngrok.yml
fi

mkdir -p /root/.config/ngrok
cp ngrok.yml /root/.config/ngrok/ngrok.yml

sleep 3
python3 selfgpt.py & ngrok http 5000 && fg
