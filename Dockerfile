#
# Include Nginx, Redis and WhoisAPI
#

# Pull base image.
FROM dockerfile/ubuntu

# Fix IPv6 DNS issue
RUN sudo echo "nameserver 8.8.8.8" > /etc/resolv.conf
RUN sudo echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# Install Nginx and Redis
RUN sudo apt-get install --reinstall ca-certificates
RUN sudo apt-get install software-properties-common
RUN sudo add-apt-repository ppa:nginx/development
RUN sudo apt-get --yes update
RUN sudo apt-get --yes upgrade --force-yes
RUN sudo apt-get --yes install supervisor nginx redis-server

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
