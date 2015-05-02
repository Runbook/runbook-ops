# Pull base image
FROM ubuntu:latest

MAINTAINER Benjamin Cane <ben@bencane.com>

# Install required packages
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget
RUN useradd -g users runapp
RUN apt-get install -y python-dev python-pip
RUN apt-get install -y libssl-dev libffi-dev git
RUN apt-get install -y stunnel supervisor
RUN rm -rf /var/lib/apt/lists/*

# Create working directories
RUN mkdir -p /code /config

# Pull application source from git
RUN git clone https://github.com/asm-products/cloudroutes-service.git --branch {{ git_branch }}

# Copy Broker Code
RUN cp -R cloudroutes-service/src/actions/* /code/

# Copy Configurations
RUN cp cloudroutes-service/src/actions/requirements.txt /config/requirements.txt
ADD config/broker.yml /config/broker.yml
ADD config/stunnel-server.conf /config/stunnel-server.conf
ADD config/supervisord.conf /config/supervisord.conf
ADD config/ssl/key.pem /config/key.pem
ADD config/ssl/cert.pem /config/cert.pem
RUN chown -R runapp:users /config /code

# Install requirements
RUN pip install -r /config/requirements.txt

EXPOSE {{ exposed_sink_port }}
EXPOSE {{ exposed_actioner_port }}

# Command to run
CMD /usr/bin/supervisord -c /config/supervisord.conf
