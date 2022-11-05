FROM buildpack-deps:bullseye

LABEL maintainer="Viertelwissen <info@viertelwissen.de>"

# Versions of Nginx and nginx-rtmp-module to use
ENV NGINX_VERSION nginx-1.22.0
ENV NGINX_RTMP_MODULE_VERSION 1.2.2

# Install dependencies
RUN apt-get update && \
    apt-get install -y ca-certificates openssl libssl-dev stunnel4 gettext apache2-utils && \
    rm -rf /var/lib/apt/lists/*

# Download and decompress Nginx
RUN mkdir -p /tmp/build/nginx && \
    cd /tmp/build/nginx && \
    wget -O ${NGINX_VERSION}.tar.gz https://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxf ${NGINX_VERSION}.tar.gz

# Download and decompress RTMP module
RUN mkdir -p /tmp/build/nginx-rtmp-module && \
    cd /tmp/build/nginx-rtmp-module && \
    wget -O nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}.tar.gz https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
    tar -zxf nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
    cd nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}

# Build and install Nginx
# The default puts everything under /usr/local/nginx, so it's needed to change
# it explicitly. Not just for order but to have it in the PATH
RUN cd /tmp/build/nginx/${NGINX_VERSION} && \
    ./configure \
        --sbin-path=/usr/local/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/var/run/nginx/nginx.pid \
        --lock-path=/var/lock/nginx/nginx.lock \
        --http-log-path=/var/log/nginx/access.log \
        --http-client-body-temp-path=/tmp/nginx-client-body \
        --with-http_ssl_module \
        --with-threads \
        --with-ipv6 \
        --with-http_realip_module \
        --add-module=/tmp/build/nginx-rtmp-module/nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION} && \
    make -j $(getconf _NPROCESSORS_ONLN) && \
    make install && \
    mkdir /var/lock/nginx && \
    rm -rf /tmp/build

# Forward logs to Docker
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Remove default config
RUN rm -f /etc/nginx/nginx.conf

# Set up config file
COPY nginx/nginx.conf.template /etc/nginx/nginx.conf.template

# Set up stat page
COPY nginx_html /usr/local/nginx/html
COPY nginx_stat /usr/local/nginx/html/stat

# Config Stunnel
RUN mkdir -p  /etc/stunnel/conf.d
# Set up config file 
COPY stunnel/stunnel.conf /etc/stunnel/stunnel.conf
COPY stunnel/stunnel4 /etc/default/stunnel4

#Facebook Stunnel Port 19350
COPY stunnel/fb.conf /etc/stunnel/conf.d/fb.conf

#Instagram Stunnel Port 19351
COPY stunnel/instagram.conf /etc/stunnel/conf.d/instagram.conf

#Application name
ENV APPLICATION_NAME live

#Twitch
ENV TWITCH_URL rtmp://live.twitch.tv/app/
ENV TWITCH_KEY ""

#Youtube
ENV YOUTUBE_URL rtmp://a.rtmp.youtube.com/live2/
ENV YOUTUBE_KEY ""

#Trovo
ENV TROVO_URL rtmp://livepush.trovo.live/live/
ENV TROVO_KEY ""

#Facebook
ENV FACEBOOK_URL rtmp://127.0.0.1:19350/rtmp/
ENV FACEBOOK_KEY ""

#Instagram
ENV INSTAGRAM_URL rtmp://127.0.0.1:19351/rtmp/
ENV INSTAGRAM_KEY ""

#Web-User
ENV WEB_USER ""

#Web-Password
ENV WEB_PASSWORD ""

ENV DEBUG ""

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

EXPOSE 1935

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
