#!/bin/bash
service nginx start
consul-template -consul-addr=$CONSUL_URL 
-template="/templates/myapp.ctmpl:/etc/nginx/conf.d/myapp.conf:service nginx reload"
