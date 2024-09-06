FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ARG GEOIP_ACCOUNT_ID
ARG GEOIP_LICENSE_KEY

RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    curl \
    git \
    build-essential \
    gcc \
    libpcre3 \
    libpcre3-dev \
    zlib1g-dev \
    libmaxminddb0 \
    libmaxminddb-dev \
    mmdb-bin \
    geoipupdate \
    nginx \
    cron \
    && add-apt-repository ppa:maxmind/ppa -y \
    && apt-get update \
    && apt-get install -y nginx libmaxminddb0 libmaxminddb-dev mmdb-bin geoipupdate \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "AccountID ${GEOIP_ACCOUNT_ID}\nLicenseKey ${GEOIP_LICENSE_KEY}\nEditionIDs GeoLite2-Country GeoLite2-City" > /etc/GeoIP.conf \
    && echo "0 0 * * * /usr/bin/geoipupdate" > /etc/cron.d/geoipupdate \
    && /usr/bin/geoipupdate

RUN mkdir -p /usr/src/nginx-compile \
    && cd /usr/src/nginx-compile \
    && git clone https://github.com/leev/ngx_http_geoip2_module.git \
    && wget http://nginx.org/download/nginx-1.18.0.tar.gz \
    && tar zxvf nginx-1.18.0.tar.gz \
    && cd nginx-1.18.0 \
    && ./configure --with-compat --add-dynamic-module=/usr/src/nginx-compile/ngx_http_geoip2_module \
    && make \
    && make install \
    && mkdir -p /usr/share/nginx/modules \
    && cp /usr/local/nginx/modules/ngx_http_geoip2_module.so /usr/share/nginx/modules/ \
    && cd /usr \
    && rm -rf /usr/src/nginx-compile

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]