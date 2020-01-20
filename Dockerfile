FROM balenalib/rpi-python:3.7.6-latest-build

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git vim

RUN pip install -U pip && \
    pip install pipenv

RUN mkdir -p /root/workspace
RUN pip install async-timeout==3.0.1
RUN cd /root/workspace/ && git clone https://fengding2:a17887f643068ce63b65b5cb816947a79c7b135e@github.com/WeConnect/eventcollector-python.git
RUN cd /root/workspace/eventcollector-python && python3 setup.py install

WORKDIR /root/workspace
COPY . .
RUN pipenv lock --requirements > requirements.txt
RUN pip install -r /root/workspace/requirements.txt

ENV FLASK_APP=/root/workspace/src/app.py
ENV APP_ALIVE 30
ENV APP_DEBUG "True"
ENV APP_EVENT ""
ENV APP_ENV "dev"

VOLUME [ "/root/workspace/src/logs" ]

WORKDIR /root/workspace/src
CMD ["gunicorn", "-b", ":5000", "-e", "APP_ALIVE=${APP_ALIVE}", "-e", "APP_DEBUG=${APP_DEBUG}",  "-e", "APP_EVENT=${APP_EVENT}",  "-e", "APP_ENV=${APP_ENV}", "app:app"]