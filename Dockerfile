FROM jwei/steamcmd:latest

ENV CHECK_UPDATE 0

COPY start.sh /start.sh

USER root
RUN set -x \
 && chown steam:steam /start.sh \
 && chmod 755 /start.sh
USER steam

CMD [ "/start.sh" ]
