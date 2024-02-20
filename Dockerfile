FROM python:3.9-alpine

COPY . /app

WORKDIR /app

RUN apk add --no-cache gcc musl-dev libffi-dev openssl-dev jq && \
    pip install --upgrade pip && \
    pip install -r requirements.txt

RUN chmod +x entrypoint.sh

VOLUME ["/app/output"]

# Entrypoint
ENTRYPOINT ["sh", "entrypoint.sh"]
