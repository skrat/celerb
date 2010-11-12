$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'rubygems'

require 'mq'
require 'msgpack'
require 'uuid'

module Celerb
  VERSION = '0.0.1'
end

require 'celerb/task'
require 'celerb/task_proto'
require 'celerb/task_publisher'
