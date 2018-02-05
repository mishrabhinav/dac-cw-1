# Matthew Brookes (mb5715) and Abhinav Mishra (am8315)
#! /bin/bash

echo "Starting System${SYSTEM_NO:-1}"
pushd ./System${SYSTEM_NO:-1} > /dev/null
docker-compose up --build
docker-compose rm -f
popd > /dev/null
