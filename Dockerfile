#syntax=docker/dockerfile:1.4
FROM python:3
RUN apt update
RUN apt -y install curl
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
    | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
    && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
    | tee /etc/apt/sources.list.d/ngrok.list \
    && apt update \
    && apt -y install ngrok
# RUN pip install --upgrade pip
RUN mkdir /SelfGPT
WORKDIR /SelfGPT
COPY --from=requirements . .
RUN pip install -r requirements.txt
RUN apt -y install jq
RUN apt -y install ffmpeg
COPY . .
COPY --from=docker . .
EXPOSE 5000
CMD ["bash", "start.sh"]
