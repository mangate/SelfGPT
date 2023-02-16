#syntax=docker/dockerfile:1.4
FROM ubuntu
RUN apt update
RUN apt -y install curl python3 pip
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
    | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
    && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
    | tee /etc/apt/sources.list.d/ngrok.list \
    && apt update \
    && apt -y install ngrok
RUN pip install --upgrade pip
RUN mkdir /SelfGPT
COPY selfgpt.py requirements.txt /SelfGPT
WORKDIR /SelfGPT
RUN pip install -r requirements.txt
COPY --from=runtime-context . .
CMD ["bash", "start.sh"]
