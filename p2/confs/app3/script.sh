#!/bin/bash

set -e

export KERNEL=$(uname -r)

envsubst < /root/index_template_app3.html > /usr/share/nginx/html/index.html
