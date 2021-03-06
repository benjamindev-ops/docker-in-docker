# base
FROM ubuntu:18.04

# set the github runner version https://github.com/actions/runner/releases
ARG RUNNER_VERSION="2.286.0"

RUN apt-get update -y && apt-get upgrade -y && apt-get install curl -y

RUN  useradd -m githubactions

# Install docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh get-docker.sh

# update the base packages and add a non-sudo user
# RUN apt-get update -y && apt-get upgrade -y && && apt-get install curl -y && useradd -m githubactions
#RUN usermod -aG sudo docker 
RUN usermod -aG sudo githubactions
RUN usermod -aG docker githubactions
RUN newgrp docker

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/githubactions && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R githubactions  ~githubactions && /home/githubactions/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER githubactions

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
