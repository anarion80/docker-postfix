#!/bin/sh
cd $(dirname $0)/../../
docker build . -t anarion/postfix && \
docker run -it --rm --name postfix -p 1587:587 $* anarion/postfix
