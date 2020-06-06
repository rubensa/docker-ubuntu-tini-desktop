#!/usr/bin/env bash

docker build --no-cache \
  -t "rubensa/custom-ubuntu-tini-desktop" \
  --label "maintainer=Ruben Suarez <rubensa@gmail.com>" \
  .
