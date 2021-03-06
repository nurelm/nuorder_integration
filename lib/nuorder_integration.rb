$:.unshift File.dirname(__FILE__)

require 'nuorder_connector/connector'

require 'nuorder_services/base'

Dir[App.root.join("lib/nuorder_services/**/*.rb")].each { |file| require file }
Dir[App.root.join("lib/models/**/*.rb")].each { |file| require file }
Dir[App.root.join("lib/mappers/**/*.rb")].each { |file| require file }
Dir[App.root.join("lib/serializers/**/*.rb")].each { |file| require file }

