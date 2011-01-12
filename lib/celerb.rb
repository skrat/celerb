$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'rubygems'

require 'mq'
require 'msgpack'
require 'uuid'

module Celerb
  VERSION = '0.2.5'
end

require 'celerb/task'
require 'celerb/task_publisher'
require 'celerb/result_consumer'
