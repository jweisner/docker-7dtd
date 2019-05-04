FROM jwei/steamcmd:latest

LABEL maintainer="jesse@weisner.ca"

ENV CONFIG_FILE /data/serverconfig.xml

COPY start.sh /home/steam/start.sh

USER root
RUN set -x \
 && chown steam:steam /home/steam/start.sh \
 && chmod 755 /home/steam/start.sh \
 && mkdir /home/steam/overrides
USER steam

VOLUME /home/steam/overrides

WORKDIR /data

CMD /home/steam/start.sh
