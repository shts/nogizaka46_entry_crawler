require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

#TODO: for local
#ActiveRecord::Base.configurations = YAML.load_file('database.yml')
#ActiveRecord::Base.establish_connection(:development)
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
