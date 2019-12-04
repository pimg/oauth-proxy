FROM  openresty/openresty:centos

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

ENTRYPOINT [ "nginx" ]
CMD [ "-p", "/myapp/", "-c", "conf/nginx.conf" ]