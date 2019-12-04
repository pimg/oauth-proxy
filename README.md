# OAuth proxy

Install Openresty dependencies:

opm --cwd get openresty/lua-resty-lrucache

opm --cwd get agentzh/lua-resty-http

Start the server with:

bin/start_nginx

Build container with Podman using the Dockerfile
podman build -t local/oauth-proxy  .

and run the container with podman:
podman run -it --rm -p 8080:8080 rubix/oauth-proxy