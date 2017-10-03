FROM ubuntu
MAINTAINER erikwilson

# If you want to tinker with this Dockerfile on your machine do as follows:
# - git clone https://github.com/erikwilson/docker-ubuntu-dev-tools
# - vim docker-ubuntu-dev-tools/Dockerfile
# - docker build -t docker-ubuntu-dev-tools docker-ubuntu-dev-tools
# - cd <nodemcu-firmware>
# - docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware docker-ubuntu-dev-tools

RUN apt-get update && apt-get install -y wget unzip git make python-serial srecord bc xz-utils gcc ccache gperf bison flex libncurses5-dev
