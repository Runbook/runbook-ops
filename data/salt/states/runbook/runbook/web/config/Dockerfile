# Pull base image
FROM ubuntu:latest

MAINTAINER Benjamin Cane <ben@bencane.com>

# Update
RUN apt-get update
RUN apt-get upgrade -y

# Install required packages
RUN useradd -g users runapp
RUN apt-get install -y python python-dev python-pip python-virtualenv wget unzip
RUN apt-get install -y libssl-dev libffi-dev git
RUN apt-get install -y stunnel supervisor
RUN apt-get install -y nginx uwsgi uwsgi-plugins-all
RUN rm -rf /var/lib/apt/lists/*

# Create working directories
RUN mkdir -p /code /config /data
RUN mkdir -p /data/runstatic/public_html

# Pull application source from git
RUN git clone https://github.com/asm-products/cloudroutes-service.git --branch {{ git_branch }}

# Copy Code
RUN cp -R cloudroutes-service/src/web/* /code/
# Copy static files
RUN cp -R cloudroutes-service/src/web/static /data/runstatic/public_html/

# Copy Configurations
RUN cp cloudroutes-service/src/web/requirements.txt /config/requirements.txt
ADD config/web.cfg /code/instance/web.cfg
ADD config/stunnel-client.conf /config/stunnel-client.conf
ADD config/supervisord.conf /config/supervisord.conf
ADD config/ssl/key.pem /config/key.pem
ADD config/ssl/cert.pem /config/cert.pem
ADD config/nginx/nginx.conf /etc/nginx/nginx.conf
ADD config/nginx/conf.d/uwsgi.conf /etc/nginx/conf.d/uwsgi.conf
ADD config/nginx/globals/htmlglobal.conf /etc/nginx/globals/htmlglobal.conf
ADD config/nginx/globals/uwsgi.conf /etc/nginx/globals/uwsgi.conf
ADD config/nginx/sites-enabled/dash.runbook.io.conf /etc/nginx/sites-enabled/dash.runbook.io.conf
ADD config/nginx/sites-enabled/dash.cloudrout.es.conf /etc/nginx/sites-enabled/dash.cloudrout.es.conf
ADD config/nginx/sites-enabled/cloudrout.es.conf /etc/nginx/sites-enabled/cloudrout.es.conf
ADD config/nginx/sites-enabled/runbook.io.conf /etc/nginx/sites-enabled/runbook.io.conf
ADD config/uwsgi.cfg /config/uwsgi.cfg
ADD config/genstatic.py /code/genstatic.py

# Install requirements
RUN chown -R runapp:users /code /config /data/runstatic
RUN pip install -r /config/requirements.txt

# Command to run
CMD /usr/bin/supervisord -c /config/supervisord.conf
