# Base image
FROM ruby:3.2

# Set the Secret Key base
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    nodejs \
    yarn \
    default-mysql-client \
    default-libmysqlclient-dev \
    chromium-driver \
    libnss3 \
    xvfb

# Intall this so it can work with Scylla
RUN apt-get update && apt-get install -y iproute2

# Install bundler
RUN gem install bundler

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy application files
COPY . .

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 rails assets:precompile

# Precompile assets (if necessary)
RUN RAILS_ENV=production bundle exec rails assets:clobber
RUN RAILS_ENV=production bundle exec rails assets:precompile
# RUN RAILS_ENV=production bundle exec rake assets:precompile

# Copy the entrypoint script
COPY entrypoint.sh /usr/bin/
ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]


# Expose port
EXPOSE 3000

# Command to start the app
CMD ["rails", "server", "-b", "0.0.0.0"]