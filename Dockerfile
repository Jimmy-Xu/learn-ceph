FROM ceph/demo
MAINTAINER xjimmyshcn@gmail.com

RUN wget http://mirrors.163.com/.help/sources.list.trusty -O /etc/apt/sources.list
RUN echo "deb http://security.ubuntu.com/ubuntu trusty-security main" >> /etc/apt/sources.list
RUN apt-get update

#patch for install python-pip
RUN wget http://launchpadlibrarian.net/233817857/linux-libc-dev_3.13.0-75.119_amd64.deb
RUN dpkg -i linux-libc-dev_3.13.0-75.119_amd64.deb

#xmllint process xml(libxml2-utils include xmllint)
#jq process json
RUN apt-get install -y python-pip curl libxml2-utils jq
RUN pip install s3cmd
RUN pip install python-swiftclient
RUN apt-get install -y vim
RUN echo "export TERM=vt100" >> /root/.bashrc

##################################################
# Add bootstrap script
ADD entrypoint.sh /entrypoint.sh

# Add volumes for Ceph config and data
VOLUME ["/etc/ceph","/var/lib/ceph","/var/log/ceph"]

# Expose the Ceph ports
# (change 80 to 8800, avoid conflict with other web server
# change 5000 to 5500, avoid conflict with docker register)
EXPOSE 6789 6800 6801 6802 6803 6804 6805 8800 5500

# Execute the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
