FROM  openresty/openresty:centos

RUN PATH=/usr/local/openresty/nginx/sbin:$PATH
RUN export PATH

ENV AUTHORIZATION_URL=""
ENV CLIENT_ID=""
ENV CLIENT_SECRET=""
ENV UPSTREAM_URL=""

EXPOSE 8080/tcp
RUN mkdir -p /myapp
WORKDIR /myapp

RUN opm --cwd get openresty/lua-resty-lrucache
RUN opm --cwd get agentzh/lua-resty-http
COPY . .

RUN chmod +x /myapp/bin/start_nginx

ENTRYPOINT [ "/myapp/bin/start_nginx" ]