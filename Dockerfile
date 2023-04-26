FROM ruby:2.2.10

RUN apt-get update -qq
RUN apt-get upgrade -y --force-yes
RUN apt-get install -y --force-yes \
  apt-transport-https \
  build-essential \
  postgresql-client \
  libpq-dev \
  cmake \
  curl \
  git-core  \
  make \
  gcc \
  openjdk-7-jdk \
  xvfb \
  openssl

# wkhtmltopdf
RUN curl -O -J -L https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar xvf wkhtmltox*.tar.xz
RUN mv wkhtmltox/bin/wkhtmlto* /usr/bin
RUN apt-get install -y --force-yes \
  xfonts-75dpi \
  libssl-dev \
  libxrender-dev \
  libx11-dev \
  libxext-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  fontconfig
RUN ln -s /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf;
RUN chmod +x /usr/local/bin/wkhtmltopdf;

ENV APP_PATH /usr/src/app
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV LIB_GIT2_COMPILE_PATH /opt

RUN curl https://deb.nodesource.com/setup_10.x | bash
RUN apt-get --allow-unauthenticated install -y nodejs
RUN npm install npm@6.9 -g
RUN npm install bower@1.8.8 -g

RUN gem uninstall -i /usr/local/lib/ruby/gems/2.2.0 bundler
RUN gem install bundler -v 1.17.3
RUN gem install rake -v 12.3.3

# Debugger
RUN gem install ruby-debug-ide
RUN gem install debase
RUN gem install byebug -v 10.0.2

# add credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
COPY id_ecdsa /root/.ssh/id_ecdsa
COPY id_ecdsa.pub /root/.ssh/id_ecdsa.pub

RUN chmod 0700 /root/.ssh && \
  chmod 0400 /root/.ssh/id_ecdsa && \
  chmod 0644 /root/.ssh/id_ecdsa.pub && \
  ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN mkdir /saudesimples
WORKDIR /saudesimples

COPY saudesimples/Gemfile /saudesimples/Gemfile
COPY saudesimples/Gemfile.lock /saudesimples/Gemfile.lock

RUN bundle install

EXPOSE 4000
EXPOSE 8080

CMD ["rails", "server", "-p", "4000"]