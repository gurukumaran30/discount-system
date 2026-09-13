FROM python:3.11-slim

WORKDIR /usr/src/app

COPY ./flask/requirements.txt /usr/src/app/requirements.txt
RUN pip install --no-cache-dir -r /usr/src/app/requirements.txt

# Copy the whole repo so the flask service can import modules
COPY . /usr/src/app

ENV FLASK_APP=app/main.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5000

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
