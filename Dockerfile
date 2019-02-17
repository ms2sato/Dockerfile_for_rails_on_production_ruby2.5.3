# PRE BUILD: for bundle install and assets:precompile
FROM ruby:2.5.3-alpine as builder

ENV LANG ja_JP.UTF-8
ENV RAILS_ENV=production

RUN apk --no-cache --update add \
    build-base \
    curl-dev \
    git \
    nodejs \
    yarn \
    postgresql-dev \
    tzdata \
    linux-headers
RUN gem install bundler

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle install --jobs=4 --retry=5 --without development test

#COPY package.json yarn.lock /app/
#RUN yarn install

ADD . /app
RUN bundle exec rake assets:precompile

# BUILD: for creating image
FROM ruby:2.5.3-alpine

ENV LANG ja_JP.UTF-8
ENV RAILS_ENV=production

RUN apk add -U --no-cache \
  bash \
  libpq \
  nodejs \
  tzdata

RUN mkdir /app
WORKDIR /app

ADD . /app
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app/public/assets /app/public/assets

CMD ["./boot.sh"]
