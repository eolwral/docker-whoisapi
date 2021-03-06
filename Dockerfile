#
# Include Nginx, Redis and WhoisAPI
#

# Pull base image.
FROM library/ubuntu

# Install Nginx and Redis
RUN apt-get --yes update
RUN apt-get --yes install --reinstall ca-certificates 
RUN apt-get --yes install software-properties-common
RUN add-apt-repository ppa:nginx/development
RUN apt-get --yes update
RUN apt-get --yes upgrade --force-yes
RUN apt-get --yes install supervisor nginx redis-server wget

# Cleanup
RUN rm -rf /var/lib/apt/lists/*

# Configure Redis
RUN sed 's/^daemonize yes/daemonize no/' -i /etc/redis/redis.conf 

# Install WhoisAPI
RUN mkdir -p /var/log/server
RUN wget https://drone.io/github.com/eolwral/proxy-whoisapi/files/src/server -O /usr/bin/server
RUN chmod 775 /usr/bin/server

# Add customized supvervisor configuration
ADD ./supervisord.conf /etc/supervisord.conf

# Define mountable directories.
VOLUME ["/etc/nginx", "/var/log/nginx", "/var/lib/redis", "/var/log/redis", "/var/log/supervisor", "/var/log/server"]

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

# Expose ports.
EXPOSE 443
