FROM ubuntu:18.04 AS base

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  fonts-noto-cjk \
  ruby \
  ruby-nokogiri

RUN curl -L https://builds.wkhtmltopdf.org/0.12.6-dev/wkhtmltox_0.12.6-0.20180618.3.dev.e6d6f54.bionic_amd64.deb -o /tmp/wkhtmltox.deb && \
  apt-get install -y /tmp/wkhtmltox.deb && \
  rm /tmp/wkhtmltox.deb

RUN curl http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz -o /tmp/kindlegen_linux_2.6_i386_v2_9.tar.gz && \
  tar -xzf /tmp/kindlegen_linux_2.6_i386_v2_9.tar.gz -C /tmp && \
  mv /tmp/kindlegen /usr/bin/ && \
  rm /tmp/kindlegen_linux_2.6_i386_v2_9.tar.gz

RUN gem install bundler -v 2.0.2

WORKDIR /asciibook

FROM base AS dev

COPY asciibook.gemspec /asciibook/asciibook.gemspec
COPY Gemfile /asciibook/Gemfile
COPY lib/asciibook/version.rb /asciibook/lib/asciibook/version.rb
RUN bundle install

FROM base AS builder

COPY . /asciibook
RUN gem build asciibook.gemspec

FROM base AS release

COPY --from=builder /asciibook/asciibook-*.gem /tmp
RUN gem install /tmp/asciibook-*.gem
