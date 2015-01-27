# Pull base image
FROM dockerfile/ubuntu

MAINTAINER Benjamin Cane <ben@bencane.com>

# Update
RUN apt-get update
RUN apt-get upgrade -y

# Install required packages
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
ADD config/broker.yml /config/broker.yml
ADD config/stunnel-server.conf /config/stunnel-server.conf
ADD config/supervisord.conf /config/supervisord.conf
ADD config/ssl/key.pem /config/key.pem
ADD config/ssl/cert.pem /config/cert.pem

# Install requirements
RUN pip install -r /config/requirements.txt

EXPOSE {{ exposed_control_port }}
EXPOSE {{ exposed_worker_port }}

# Command to run
CMD /usr/bin/supervisord -c /config/supervisord.conf
