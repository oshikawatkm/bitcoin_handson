FROM ruby:3.0.0
RUN apt-get update -qq && apt-get install libleveldb-dev -y

RUN mkdir myapp
WORKDIR /myapp

# install nodejs(LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt-get install -y nodejs

# install yarn
RUN npm install --global yarn

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN gem install bitcoinrb

COPY . /myapp