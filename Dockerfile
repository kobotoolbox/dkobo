FROM ubuntu:trusty

RUN apt-get update
RUN apt-get install -y \
    python-virtualenv \
    python2.7-dev \
    libxml2 libxml2-dev libxslt1-dev \
    postgresql-server-dev-9.3 \
    git

# http://stackoverflow.com/questions/31015392/cant-npm-install-dependencies-when-building-docker-image
RUN apt-get install -y \
    nodejs-legacy npm \
    ruby

RUN virtualenv /appenv
RUN . /appenv/bin/activate

RUN mkdir /app
WORKDIR /app
ADD . /app

RUN pip install -r requirements.txt

RUN npm install
RUN npm install -g bower grunt-cli
RUN bower install --allow-root
RUN grunt build
RUN gem install foreman

RUN python manage.py syncdb --noinput
RUN python manage.py migrate

EXPOSE 5000
CMD ["foreman", "start"]
