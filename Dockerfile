# vim:set ft=dockerfile:
ARG BASEIMAGE=ubuntu:rolling
FROM $BASEIMAGE
MAINTAINER Stephan Zander

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C

ARG TARGETPLATFORM
ARG VERSION=10.4.1

ENV GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/data" \
    GF_PATHS_HOME="/usr/src/app" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

WORKDIR /usr/src/app

RUN apt-get update && apt-get install --no-install-recommends -y -q \
    ca-certificates \
    curl \
 && curl -sL https://dl.grafana.com/oss/release/grafana-$VERSION.linux-$(echo $TARGETPLATFORM | sed 's/\/v7/v7/' | sed 's/linux\///').tar.gz -o /tmp/grafana.tar.gz \
 && tar xzvf /tmp/grafana.tar.gz -C $GF_PATHS_HOME --strip-components=1 \
 && ln -s $GF_PATHS_HOME/bin/grafana-cli /usr/local/bin \
 && ln -s $GF_PATHS_HOME/bin/grafana-server /usr/local/bin \
 && rm -rf /tmp/grafana.tar.gz \
 && mkdir -p $GF_PATHS_PLUGINS $GF_PATHS_DATA \
 && chown -R nobody:nogroup $GF_PATHS_DATA $GF_PATHS_PLUGINS \
 && chmod 777 $GF_PATHS_DATA $GF_PATHS_PLUGINS \
 && apt-get remove --purge --autoremove -y -q \
    curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/ \
 && mkdir -p /var/lib/grafana/dashboards $GF_PATHS_PROVISIONING && mkdir $GF_PATHS_PROVISIONING/alerting $GF_PATHS_PROVISIONING/dashboards $GF_PATHS_PROVISIONING/datasources $GF_PATHS_PROVISIONING/notifiers $GF_PATHS_PROVISIONING/plugins

# grafana-cli plugins install grafana-piechart-panel \
# grafana-cli plugins install grafana-simple-json-datasource \
# grafana-cli plugins install blackmirror1-singlestat-math-panel \
# grafana-cli plugins install snuids-trafficlights-panel \
# grafana-cli plugins install corpglory-progresslist-panel \
# grafana-cli plugins install bessler-pictureit-panel \
# grafana-cli plugins install pierosavi-imageit-panel \
# grafana-cli plugins install larona-epict-panel \
# grafana-cli plugins install agenty-flowcharting-panel \
# grafana-cli plugins install jdbranham-diagram-panel \

COPY entrypoint.sh /entrypoint.sh
COPY filesystem.yaml $GF_PATHS_PROVISIONING/dashboards/filesystem.yaml
COPY grafana.ini /etc/grafana/grafana.ini

USER nobody
EXPOSE 3000/tcp
VOLUME /data

ENTRYPOINT ["/entrypoint.sh"]
CMD ["grafana-server"]
