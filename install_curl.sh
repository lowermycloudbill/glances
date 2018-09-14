#!/bin/bash

if [[ `apt-get 2>/dev/null` ]]; then
  apt-get update && apt-get install -y curl
fi
