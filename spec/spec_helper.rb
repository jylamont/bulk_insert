require 'rubygems'
require 'bundler/setup'
require 'bulk_insert'

Dir[::File.expand_path('../support/**/*.rb',  __FILE__)].each { |f| require f }

RSpec.configure do |config|
  ActiveRecord::Base.establish_connection(
    adapter:    'postgresql',
    host:       'localhost',
    database:   'default',
    username:   'default',
    password:   '',
    port:       5432
  )
end