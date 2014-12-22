ENV['FRAMEWORK_ENV'] = 'test'

require_relative '../config/environment'
require 'framework/migration'
ActiveRecord::Migrator.migrate('db/migrate/')

require 'factory_girl'
FactoryGirl.definition_file_paths.unshift 'spec/support/factories'
FactoryGirl.reload

RSpec.configure do |c|
  c.color = true
  c.order = :rand
  c.include FactoryGirl::Syntax::Methods
end
