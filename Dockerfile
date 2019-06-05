FROM centos:7
MAINTAINER Vinicio Valbuena <vinicio.valbuena@hoplasoftware.com>

ARG GF_UID=472
ARG GF_GID=472

ENV PATH=/grafana/bin:$PATH \
    GF_PATHS_HOME="/grafana" \
    GF_PATHS_CONFIG="/grafana/conf/defaults.ini" \
    GF_PATHS_DATA="/grafana/data" \
    GF_PATHS_LOGS="/grafana/logs" \
    GF_PATHS_PLUGINS="/grafana/plugins" \
    GF_PATHS_PROVISIONING="/grafana/provisioning"

ARG GO_VERSION=1.12.5
ARG NODEJS_VERSION=10.16.0

ADD build.sh /bin/build.sh
ADD entrypoint.sh /bin/entrypoint.sh

RUN	yum install -y bzip2 gcc gcc-c++ wget git make; \
	sh /bin/build.sh

EXPOSE 3000
USER grafana

ENTRYPOINT ["sh", "/bin/entrypoint.sh"]
