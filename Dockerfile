FROM nginx:latest

ENTRYPOINT ["/bin/start.sh"]
EXPOSE 80
VOLUME /templates
ENV CONSUL_URL consul:8500

ADD start.sh /bin/start.sh
RUN chmod +x /bin/start.sh  # Ensure start.sh is executable
ADD nginx.conf /etc/nginx/nginx.conf
RUN rm -rf /etc/nginx/conf.d/*

ADD https://releases.hashicorp.com/consul-template/0.19.5/consul-template_0.19.5_linux_amd64.tgz /usr/bin/consul-template.tgz
RUN tar -C /usr/local/bin -zxf /usr/bin/consul-template.tgz \
    && mv /usr/local/bin/consul-template /usr/bin/consul-template
