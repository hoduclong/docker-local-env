FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends tini tzdata nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/public_html /run/php && \
    groupadd -g 1000 nginx && \
    useradd -u 1000 -g nginx -M -d /home/nginx -s /bin/false nginx && \
    chown -R nginx:nginx /home/public_html/

RUN ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

WORKDIR /home/public_html

ADD conf/nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["nginx", "-g", "daemon off;"]
