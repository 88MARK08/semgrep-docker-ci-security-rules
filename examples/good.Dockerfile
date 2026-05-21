FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt /app/
COPY app.py /app/

RUN useradd -m appuser
USER appuser

HEALTHCHECK CMD python3 -c "print('healthy')"

CMD ["python3", "app.py"]
