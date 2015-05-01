# Pull base image
FROM ubuntu:latest

MAINTAINER Benjamin Cane <ben@bencane.com>

# Install required packages
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget 
RUN useradd -g users runapp
RUN apt-get install -y python python-dev python-pip python-virtualenv wget unzip
RUN apt-get install -y libssl-dev libffi-dev git
RUN apt-get install -y stunnel supervisor
RUN rm -rf /var/lib/apt/lists/*

# Create working directories
RUN mkdir -p /code /config

# Pull application source from git
RUN git clone https://github.com/asm-products/cloudroutes-service.git --branch {{ git_branch }}

# Copy Broker Code
RUN cp -R cloudroutes-service/src/monitors/* /code/

# Copy Configurations
RUN cp cloudroutes-service/src/monitors/requirements.txt /config/requirements.txt
ADD config/worker.yml /config/worker.yml
ADD config/stunnel-client.conf /config/stunnel-client.conf
ADD config/supervisord.conf /config/supervisord.conf
ADD config/ssl/key.pem /config/key.pem
ADD config/ssl/cert.pem /config/cert.pem
RUN chown -R runapp:users /config /code

# Install requirements
RUN pip install -r /config/requirements.txt

# Command to run
CMD /usr/bin/supervisord -c /config/supervisord.conf
