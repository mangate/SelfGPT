#!/bin/bash
mkdir -p /root/.config/ngrok

search_dir=/SelfGPT
for entry in "$search_dir"/*
do
  echo "$entry"
done

cp /SelfGPT/source/config/ngrok.yml /root/.config/ngrok/ngrok.yml

sleep 3
python3 selfgpt.py & ngrok http 5000 && fg
