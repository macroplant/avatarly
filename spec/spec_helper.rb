require 'rspec'
require 'avatarly'
require 'mini_magick'
require 'securerandom'
require 'support/avatar_expectations'
require 'fastimage'
require 'tempfile'

RSpec.configure do |config|
  config.include AvatarExpectations
end
