source 'https://rubygems.org'

gem 'highline', '~> 2.0.3'
gem 'simple_scripting', '~> 0.12.0'

group :development do
  gem 'rspec', '~> 3.10.0'
end

group :development, :test do
  gem 'byebug'
end

group :test do
  # 0.9.x has a bug that causes Date.parse to return the wrong value: https://github.com/travisjeffery/timecop/issues/222.
  # 0.8.x is also broken, but with slightly different conditions.
  #
  gem 'timecop', '~> 0.8.0'
end
