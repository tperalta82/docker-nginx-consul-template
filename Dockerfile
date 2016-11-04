FROM nginx:latest
MAINTAINER tperalta82@github.com

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq && \
    apt-get -y install wget unzip runit && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://releases.hashicorp.com/consul-template/0.16.0/consul-template_0.16.0_linux_amd64.zip -O /tmp/consul-template.zip
RUN unzip /tmp/consul-template.zip -d /usr/local/bin/
RUN rm -f /tmp/consul-template.zip
RUN apt-get -y --purge remove wget unzip
RUN apt-get -y --purge autoremove

ADD nginx.service /etc/service/nginx/run
RUN chmod a+x /etc/service/nginx/run
ADD consul-template.service /etc/service/consul-template/run
RUN chmod a+x /etc/service/consul-template/run

RUN rm -v /etc/nginx/conf.d/*
ADD nginx.conf /etc/consul-templates/nginx.conf
ADD status.conf /etc/nginx/conf.d/status.conf

CMD ["/usr/bin/runsvdir", "/etc/service"]
