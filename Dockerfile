FROM kobotoolbox/base-dkobo:docker_local

MAINTAINER Serban Teodorescu, teodorescu.serban@gmail.com

COPY docker/run_wsgi /etc/service/wsgi/run
COPY docker/*.sh docker/koboform.ini /srv/src/

RUN chmod +x /etc/service/wsgi/run && \
    chown -R wsgi /srv/src/koboform

USER wsgi

RUN cd /srv/src/koboform && \
    bower install --config.interactive=false && \
    npm --no-color install --save-dev

COPY . /srv/src/koboform/
COPY ./docker/init.sh /etc/my_init.d/00_init.bash
COPY ./docker/sync_static.sh /etc/my_init.d/01_sync_static.bash
#COPY ./docker/create_demo_user.sh /etc/my_init.d/02_create_demo_user.bash

USER root

VOLUME ["/srv/src/koboform"]

EXPOSE 8000

CMD ["/sbin/my_init"]
