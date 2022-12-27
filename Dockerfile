FROM behren/machina-base-alpine:latest

RUN apk --update add caddy

COPY requirements.txt /tmp/
RUN pip3 install --trusted-host pypi.org \
                --trusted-host pypi.python.org \
                --trusted-host files.pythonhosted.org \
                -r /tmp/requirements.txt
RUN rm /tmp/requirements.txt

COPY docs /machina/docs
RUN cd /machina/docs && make html

CMD ["caddy", "file-server", "--access-log", "--root", "/machina/docs/build/html"]