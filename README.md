# README #

Based on the latest Nginx container template and version 0.19.5 of consul-template.

Implementing Nginx with support for streams (basic TCP proxying) 

### How do I get set up? ###

You just need to create your own start.sh that runs the consul-template command against all the files you require in your application.

```
#!/bin/bash
service nginx start
consul-template -consul-addr=$CONSUL_URL \
-template="/templates/myapp.ctmpl:/etc/nginx/conf.d/myapp.conf:service nginx reload"
```

Then run the container, mounting the templates directory and your customer start.sh

```
docker run -p 8080:80 -d --name nginx-consul -v /mnt/nginx:/templates/ -v /mny/start.sh:/bin/start.sh --link consul:consul schizoid90/nginx-consul:0.19.5
```

### Example templates ###

This template will create a Nginx .conf file with upstreams set to round-robin between all containers running the my-service services. 

```
upstream my-service {
  {{range service "my-service"}}server {{.Address}}:{{.Port}} max_fails=3 fail_timeout=60 weight=1;
  {{else}}server 127.0.0.1:65535; # force a 502{{end}}
}

server {
  listen 80;
  server_name myservice.example.com;

  charset utf-8;

  location / {
    proxy_pass http://my-service;
  }
}

```

You can get the names of services from the consul API:

```bash
curl $CONSUL_HOST:8500/v1/catalog/services
```

### Stream support ###
For cases where you aren't prxying http traffic you need to create a .strm file when writing the consul-template command in start.sh

```
...
-template="/templates/mongodb.ctmpl:/etc/nginx/conf.d/mongodb.strm:service nginx reload" \
```

### Config support ###

Nginx will search for .conf and .strm files in the /etc/nginx/conf.d directory when starting.  
Therefore all http(s) configuration should be genereated as .conf and all non http configuration should be .strm files in order to function correctly.

You can of course overwrite nginx.conf with your own by using the -v option as part of the docker run command
```
-v /my/nginx.conf:/etc/nginx/nginx.conf
```