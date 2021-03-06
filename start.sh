#!/bin/bash

ORGANIZATION=$ORGANIZATION
ACCESS_TOKEN=$ACCESS_TOKEN
ORIGIN=${ORIGIN}

REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/${ORIGIN}/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)



cd /home/githubactions/actions-runner

./config.sh --url https://github.com/${ORGANIZATION}  --unattended --token ${REG_TOKEN}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
