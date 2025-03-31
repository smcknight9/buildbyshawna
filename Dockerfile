FROM ruby:3.2.2-slim

RUN apt-get update -qq && \
    apt-get install -y build-essential git && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler

WORKDIR /srv/jekyll

# Copy ONLY Gemfile first (not Gemfile.lock)
COPY Gemfile ./

# Generate Gemfile.lock inside the container
RUN bundle install

COPY . .

RUN bundle exec jekyll build

CMD ["bundle", "exec", "jekyll", "serve", "--host=0.0.0.0", "--port=4000"]
