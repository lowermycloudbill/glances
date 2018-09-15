#!/bin/bash

if [[ `apt-get 2>/dev/null` ]]; then
  apt-get update && apt-get install -y curl
elif [[ `zypper 2>/dev/null` ]]; then
  zypper --non-interactive curl
fi
