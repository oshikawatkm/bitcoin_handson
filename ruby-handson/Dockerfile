
FROM ruby:3.0.0
RUN apt-get update -qq && apt-get install -y nodejs libsodium-dev
RUN mkdir /bitcoin-handson
WORKDIR /bitcoin-handson
COPY Gemfile /bitcoin-handson/Gemfile

COPY . /bitcoin-handson