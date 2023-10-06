FROM alpine

RUN apk update && \
    apk upgrade && \
    apk add openjdk11

RUN apk update && \
    apk upgrade && \
    apk add bash less curl jq

ARG TVD_SSL_PASSWORD=eqx_proto_1fax_?
ARG APP_HOME=/opt/app
ARG TVD_KEYSTORE_PATH=${APP_HOME}/.ssh
WORKDIR /
RUN keytool -genkeypair -keystore keystore.p12 -storetype PKCS12 -storepass ${TVD_SSL_PASSWORD} -keyalg RSA -keysize 2048 -validity 99999 -dname "CN=eqx_certificate, OU=tvd, O=anindu, L=Pittsburgh, ST=PA, C=SA"

RUN addgroup eqx
RUN adduser eqx -G eqx -D

RUN chown -R eqx keystore.p12
RUN mkdir -p ${TVD_KEYSTORE_PATH}
RUN mv keystore.p12 ${TVD_KEYSTORE_PATH}

RUN mkdir -p ${APP_HOME}
RUN chgrp -R eqx ${APP_HOME}
RUN chown -R eqx ${APP_HOME}
USER eqx

ENV TVD_SSL_PASSWORD=${TVD_SSL_PASSWORD}
ENV TVD_KEYSTORE=${TVD_KEYSTORE_PATH}/keystore.p12

WORKDIR $APP_HOME
COPY build/distributions/*.tar eqx.tar
RUN tar -xvf eqx.tar
RUN rm -rf eqx.tar
RUN mv eqx* eqx

WORKDIR $APP_HOME/eqx
EXPOSE 8383

ENTRYPOINT ['bash', '-c', 'bin/eqx']
