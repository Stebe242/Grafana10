FROM alpine:3.11.2
MAINTAINER Sebastian Braun <sebastian.braun@fh-aachen.de>
# base alpine template

ARG VERSION=6.5.2

ENV GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/data" \
    GF_PATHS_HOME="/usr/src/app" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

WORKDIR /usr/src/app

RUN apk add --no-cache libc6-compat \
 && apk add --no-cache --virtual build-dependencies curl \
 && curl -sL https://dl.grafana.com/oss/release/grafana-$VERSION.linux-amd64.tar.gz -o /tmp/grafana-$VERSION-linux-amd64.tar.gz \
 && tar xzvf /tmp/grafana-${VERSION}-linux-amd64.tar.gz -C $GF_PATHS_HOME --strip-components=1 \
 && ln -s $GF_PATHS_HOME/bin/grafana-cli /usr/local/bin \
 && ln -s $GF_PATHS_HOME/bin/grafana-server /usr/local/bin \
 && rm -rf /tmp/grafana-${VERSION}-linux-amd64.tar.gz \
 && mkdir -p $GF_PATHS_PLUGINS $GF_PATHS_DATA \
 && grafana-cli plugins install grafana-piechart-panel \
 && chown -R nobody:nobody $GF_PATHS_DATA $GF_PATHS_PLUGINS \
 && chmod 777 $GF_PATHS_DATA $GF_PATHS_PLUGINS \
 && apk del build-dependencies
# grafana-cli plugins install grafana-simple-json-datasource \
# grafana-cli plugins install blackmirror1-singlestat-math-panel \
# grafana-cli plugins install snuids-trafficlights-panel \
# grafana-cli plugins install corpglory-progresslist-panel \
# grafana-cli plugins install bessler-pictureit-panel \
# grafana-cli plugins install pierosavi-imageit-panel \
# grafana-cli plugins install larona-epict-panel \
# grafana-cli plugins install agenty-flowcharting-panel \
# grafana-cli plugins install jdbranham-diagram-panel \

COPY run.sh ./run.sh
COPY provisioning $GF_PATHS_PROVISIONING
COPY dashboards /var/lib/grafana/dashboards
COPY grafana.ini /etc/grafana/grafana.ini

USER nobody
EXPOSE 3000/tcp
VOLUME /data

ENTRYPOINT [ "./run.sh" ]
