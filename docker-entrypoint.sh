#!/bin/bash

set -e

NGINX_TEMPLATE=/etc/nginx/nginx.conf.template
NGINX_CONF=/etc/nginx/nginx.conf 
ENV_OK=0

echo "Start setup..."

if [ -n "${TWITCH_KEY}" ]; then
	echo "Twitch activated."
	sed -i 's|#twitch|push '"$TWITCH_URL"'${TWITCH_KEY};|g' $NGINX_TEMPLATE
	ENV_OK=1
else
	sed -i 's|#twitch| |g' $NGINX_TEMPLATE
fi

if [ -n "${YOUTUBE_KEY}" ]; then
	echo "Youtube activated."
	sed -i 's|#youtube|push '"$YOUTUBE_URL"'${YOUTUBE_KEY};|g' $NGINX_TEMPLATE
	ENV_OK=1
else
	sed -i 's|#youtube| |g' $NGINX_TEMPLATE
fi

if [ -n "${TROVO_KEY}" ]; then
	echo "Trovo activated."
	sed -i 's|#trovo|push '"$TROVO_URL"'${TROVO_KEY};|g' $NGINX_TEMPLATE
	ENV_OK=1
else
	sed -i 's|#trovo| |g' $NGINX_TEMPLATE
fi

if [ -n "${FACEBOOK_KEY}" ]; then
	echo "Facebook activated."
	sed -i 's|#facebook|push '"$FACEBOOK_URL"'${FACEBOOK_KEY};|g' $NGINX_TEMPLATE
	ENV_OK=1
else 
	sed -i 's|#facebook| |g' $NGINX_TEMPLATE
fi

if [ -n "${INSTAGRAM_KEY}" ]; then
	echo "Instagram activated."
	sed -i 's|#instagram|push '"$INSTAGRAM_URL"'${INSTAGRAM_KEY};|g' $NGINX_TEMPLATE
	ENV_OK=1
else 
	sed -i 's|#instagram| |g' $NGINX_TEMPLATE
fi

# setup application name (default: live)
echo "Set application name to: $APPLICATION_NAME"
sed -i 's|#application|'"$APPLICATION_NAME"'|g' $NGINX_TEMPLATE

# check for auth informations
if [ -n "${WEB_USER}" ] && [ -n "${WEB_PASSWORD}" ]; then
	echo "Values for WEB_USER and WEB_PASSWORD found, set up authentication..."
	htpasswd -bc /etc/nginx/.htpasswd "$WEB_USER" "$WEB_PASSWORD"
	sed -i 's|#auth_basic|auth_basic           "Restricted Access!";|g' $NGINX_TEMPLATE
	sed -i 's|#auth_file|auth_basic_user_file /etc/nginx/.htpasswd;|g' $NGINX_TEMPLATE
	echo "Auth setup successful."
else
	echo "WEB_USER and/or WEB_PASSWORD are empty. Statistics page will be available to public!"
	sed -i 's|#auth_basic| |g' $NGINX_TEMPLATE
	sed -i 's|#auth_file| |g' $NGINX_TEMPLATE
fi

if [ -f "$NGINX_CONF" ]; then
	echo "custom nginx conf found, using this.";
else
	envsubst < $NGINX_TEMPLATE > $NGINX_CONF
	if [ $ENV_OK -ne 1 ]; then
    	echo "No streaming key defined in environment variables and no custom config found!";
	fi
fi

if [ -n "${DEBUG}" ]; then 
	echo $NGINX_CONF
	cat $NGINX_CONF
fi

stunnel4

echo "Setup finished, starting nginx."

exec "$@"