FROM debian:jessie
MAINTAINER tperalta82@github.com

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq && \
    apt-get -y install wget unzip runit libssl1.0.0 && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://releases.hashicorp.com/consul-template/0.16.0/consul-template_0.16.0_linux_amd64.zip -O /tmp/consul-template.zip
RUN unzip /tmp/consul-template.zip -d /usr/local/bin/
RUN rm -f /tmp/consul-template.zip
RUN apt-get -y --purge remove wget unzip
RUN apt-get -y --purge autoremove

ADD debs/openresty_1.11.2.2rc1_amd64.deb /tmp/
RUN dpkg -i /tmp/openresty_1.11.2.2rc1_amd64.deb
RUN rm -f /tmp/openresty_1.11.2.2rc1_amd64.deb

ADD openresty.service /etc/service/openresty/run
RUN chmod a+x /etc/service/openresty/run
ADD consul-template.service /etc/service/consul-template/run
RUN chmod a+x /etc/service/consul-template/run

ADD app.conf /etc/consul-templates/app.conf
ADD nginx.conf /etc/consul-templates/nginx.conf
ADD lua/uuid4.lua /opt/openresty/nginx/lua/uuid4.lua
RUN mkdir /opt/openresty/nginx/conf/conf.d
ADD status.conf /opt/openresty/nginx/conf/conf.d/status.conf
RUN adduser  --group --system --shell /bin/false --no-create-home --disabled-password --home /nonexistent nginx

CMD ["/usr/bin/runsvdir", "/etc/service"]
