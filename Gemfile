source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.4.1"

# make ENVs available to lh_* gems
group :development, :test do
  gem 'dotenv-rails', require: 'dotenv/rails-now'
end

# disabled until relevant
# gem "zero_downtime_migrations"

gem "awesome_print"
gem "bootsnap", ">= 1.1.0", require: false
gem "bundler-audit", require: false
gem "excon"
gem "mini_magick"
gem "mutations"
gem "oj"
gem "paper_trail"
gem "pry-rails"
gem "puma"
gem "rails", "~> 5.2.0.rc2"
gem "rails_param"
gem "react-rails"
gem "redcarpet"
gem "sassc-rails"
# gem "secure_headers"
gem "sqlite3"
gem "table_print"
gem "uglifier"
gem "webpacker"

group :development, :test do
  gem "capybara"
  gem "chromedriver-helper"
  gem "factory_girl_rails"
  gem "faker"
  gem "rspec-rails"
  gem "rubocop", require: false
  gem "timecop"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller" # gives more context to better_errors reports
  gem "listen"
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen"
end

group :test do
  gem "pusher-fake", require: false
end
