FROM ubuntu:trusty

RUN apt-get update

RUN apt-get -y install software-properties-common

# Add Ruby-2.3.3 repository
RUN apt-add-repository -y ppa:brightbox/ruby-ng

# Add MariaDB repository
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN add-apt-repository 'deb http://www.ftp.saix.net/DB/mariadb/repo/10.0/ubuntu trusty main'

RUN apt-get update

# Fetch updates
RUN apt-get -y install wget

# Install Ruby 2.3.*
RUN echo "20171211" && apt-get -y install ruby2.3 ruby2.3-dev

# Install misc dependencies
RUN apt-get -y install build-essential patch zlib1g-dev liblzma-dev libxml2-dev libxslt1-dev libfontconfig1 libfreetype6 git curl unzip

# Install MariaDB
RUN apt-get -y install mariadb-server libmariadbclient-dev

# Install bundler
RUN gem install bundler

# Install xvfb for headless selenium
RUN apt-get -y install xvfb

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_5.x | bash -
RUN apt-get -y install nodejs

RUN apt-get -yq --no-install-suggests --no-install-recommends --force-yes install libqtwebkit-dev libqtwebkit4
RUN apt-get -y install gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x

ADD xvfb /etc/init.d/xvfb
RUN chmod a+x /etc/init.d/xvfb
