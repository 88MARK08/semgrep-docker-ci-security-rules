FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl
RUN curl https://example.com/install.sh | bash

COPY id_rsa /root/.ssh/id_rsa
COPY .env /app/.env
COPY . /app

WORKDIR /app

CMD ["python3", "app.py"]
