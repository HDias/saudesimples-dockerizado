FROM ruby:2.2.10

RUN apt-get update -qq
RUN apt-get install -y \
  build-essential \
  postgresql-client \
  libpq-dev \
  libpgsql-ruby \
  cmake \
  zlib1g-dev \
  libcppunit-dev \
  git \
  make \
  gcc \
  openjdk-7-jdk  \
  && rm -rf /var/lib/apt/lists/*

ENV APP_PATH /usr/src/app
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV LIB_GIT2_COMPILE_PATH /opt

# add credentials on build
RUN mkdir /root/.ssh/
COPY id_ecdsa /root/.ssh/id_ecdsa
COPY id_ecdsa.pub /root/.ssh/id_ecdsa.pub

RUN chmod 0700 /root/.ssh && \
  chmod 0400 /root/.ssh/id_ecdsa && \
  chmod 0644 /root/.ssh/id_ecdsa.pub

RUN curl https://deb.nodesource.com/setup_10.x | bash
RUN apt-get --allow-unauthenticated install -y nodejs
RUN npm install npm@6.9 -g
RUN npm install bower@1.8.8 -g

RUN gem uninstall -i /usr/local/lib/ruby/gems/2.2.0 bundler
RUN gem install bundler -v 1.17.3
RUN gem install rake -v 12.3.3


RUN mkdir /saudesimples
WORKDIR /saudesimples

COPY saudesimples/Gemfile /saudesimples/Gemfile
COPY saudesimples/Gemfile.lock /saudesimples/Gemfile.lock

# RUN bundle install

COPY saudesimples /saudesimples

EXPOSE 3000

# CMD ["bundle", "exec", "rails", "s", "-b 0.0.0.0"]