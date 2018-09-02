#!/bin/bash

set -ev

if [[ ${OS_TYPE} = "debian" && ${OS_VERSION} = "wheezy" ]]; then
    docker exec -it linux bash -c "pip install nose --index-url=https://pypi.python.org/simple/"
elif [[ ${OS_TYPE} = "ubuntu" && ${OS_VERSION} = "12.04" ]]; then
    docker exec -it linux bash -c "pip install nose --index-url=https://pypi.python.org/simple/"
else
    docker exec -it linux bash -c "pip install nose"
fi

exit 0;
