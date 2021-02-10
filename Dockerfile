FROM ruby:2.6.6-stretch
# FROM ruby:2.5.1-stretch

# Update the package lists before installing.
RUN apt-get update -qq

# This installs
# * build-essential because Nokogiri requires gcc
# * common CA certs
# * netcat to test the database port
# * two different text editors (emacs and vim) for emergencies
# * the mysql CLI and client library
RUN apt-get install -y \
    build-essential \
    ca-certificates \
    netcat-traditional \
    emacs \
    vim \
    postgresql

RUN sh -c "$(wget -O- https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)"

# Install node from nodesource
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get install -y nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq \
  && apt-get install -y yarn

# Create a directory called `/workdir` and make that the working directory
ENV APP_HOME /workdir
RUN mkdir ${APP_HOME}
WORKDIR ${APP_HOME}

# ENV RAILS_ENV production
ENV RAILS_ENV development
ENV RAILS_MASTER_KEY 2ba0ab62bdc62514afe6661c6642fd62

# Copy the Gemfile
COPY Gemfile ${APP_HOME}/Gemfile
COPY Gemfile.lock ${APP_HOME}/Gemfile.lock

# Make sure we are running bundler version 2.0
# RUN gem update --system
RUN gem install bundler -v 2.1.4
RUN bundle config set without 'development test'
RUN bundle install # --without development test

RUN yarn install --check-files

# Copy the project over
COPY . ${APP_HOME}

# RUN bundle exec rails assets:precompile

# CMD bundle exec rails s -p 80 -b '0.0.0.0'