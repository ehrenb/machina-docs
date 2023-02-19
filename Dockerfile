FROM behren/machina-base-alpine:latest

RUN apk --update add caddy \
    gobject-introspection \
    pango \
    fontconfig ttf-freefont font-noto terminus-font

COPY requirements.txt /tmp/
RUN pip3 install -r /tmp/requirements.txt
RUN rm /tmp/requirements.txt

RUN mkdir /docs
COPY machina /docs/machina
RUN cd /docs/machina && mkdocs build

COPY Caddyfile.dev /docs/
COPY Caddyfile.prod /docs/

# default to prod, override command can be used to
# invoke with Caddyfile.dev
CMD ["caddy", "run", "--config", "/docs/Caddyfile.prod"]