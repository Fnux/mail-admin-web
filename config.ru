puts "**********************************"
puts "[Mail-admin] Starting Web App..."

# load dependencies
require 'rubygems'
require 'sinatra'
require "yaml"
require "sequel"
#require 'digest/sha2'

# load the config file
CONFIG =  YAML.load_file('config.yml')

# if "reloader: true"
require "sinatra/reloader" if CONFIG['reloader']

# Enable sessions
use Rack::Session::Cookie, :key => 'session',
:path => '/',
:expire_after => 3600, # In seconds
:secret => CONFIG['secret']

# Connecting to the database
case CONFIG['database']['adapter']
when "sqlite3"
    DB = Sequel.connect("sqlite://#{Dir.pwd}/#{CONFIG['database']['database']}")
when "mysql"
    DB = Sequel.connect("mysql://#{CONFIG['database']['user']}:#{CONFIG['database']['password']}@#{CONFIG['database']['server']}/#{CONFIG['database']['database']}")
when "postgres"
    DB = Sequel.connect("postgres://#{CONFIG['database']['user']}:#{CONFIG['database']['password']}@#{CONFIG['database']['server']}/#{CONFIG['database']['database']}")
end

# Create the tables is needed
DB.create_table :domains do
    primary_key :id
    String :name
    DateTime :created_at
end

DB.create_table :users do
    primary_key :id
    String :mail
    Text :password
    DateTime :created_at
end

DB.create_table :aliases do
    primary_key :id
    String :source
    String :destination
    DateTime :created_at
end

# Set views directory
set :views, settings.root + '/views'

# Render ERB files using ".html.erb" extensions (instead of ".erb")
Tilt.register Tilt::ERBTemplate, 'html.erb'

# Load the application (app.rb)
require File.expand_path '../app.rb', __FILE__

# Let's run this app :3
run MailAdmin
