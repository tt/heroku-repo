Dir[File.join(File.expand_path("../vendor", __FILE__), "*")].each do |vendor|
    $:.unshift File.join(vendor, "lib")
end

require 'heroku/command/repo'

require_relative './lib/heroku/command/releases'
