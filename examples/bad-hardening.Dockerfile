FROM python:3.12-slim
RUN apt-get update && apt-get upgrade -y
RUN chmod 777 /app
USER root
CMD ["python3", "app.py"]
