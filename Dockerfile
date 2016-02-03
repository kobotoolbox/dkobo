FROM kobotoolbox/base-dkobo:latest

MAINTAINER Serban Teodorescu, teodorescu.serban@gmail.com

COPY docker/run_wsgi /etc/service/wsgi/run
COPY docker/*.sh docker/koboform.ini /srv/src/
COPY . /srv/src/koboform/

RUN chmod +x /etc/service/wsgi/run && \
    chown -R wsgi /srv/src/koboform

USER wsgi

RUN cd /srv/src/koboform && \
    bower install --config.interactive=false && \
    npm --no-color install --save-dev

USER root

VOLUME ["/srv/src/koboform"]

EXPOSE 8000

CMD ["/sbin/my_init"]
