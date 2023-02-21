#syntax=docker/dockerfile:1.4
FROM python:3

# Install jq (for ngrok tunnel url extraction) and ffmpeg (for openai-whisper)
RUN apt update
RUN apt -y install jq ffmpeg

# Install ngrok
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
    | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
    && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
    | tee /etc/apt/sources.list.d/ngrok.list \
    && apt update \
    && apt -y install ngrok

RUN mkdir /SelfGPT
WORKDIR /SelfGPT

# Download openai whisper base model (see discussion at https://github.com/mangate/SelfGPT/pull/18#issuecomment-1438731324)
RUN curl -s https://raw.githubusercontent.com/openai/whisper/main/whisper/__init__.py \
    | grep base.pt \
    | cut -d: -f2,3 \
    | cut -d'"' -f2 \
    | xargs curl -o base.pt

COPY --from=requirements . .
RUN pip install -r requirements.txt
COPY . .
COPY --from=docker . .
EXPOSE 5000
CMD ["bash", "start.sh"]
