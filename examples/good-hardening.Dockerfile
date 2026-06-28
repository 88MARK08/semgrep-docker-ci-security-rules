FROM python:3.12-slim
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
RUN chmod 755 /app
RUN useradd --create-home appuser
USER appuser
CMD ["python3", "app.py"]
