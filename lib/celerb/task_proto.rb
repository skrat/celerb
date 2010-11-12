require 'base64'

module Celerb
  # Protocol buffers specific task
  module ProtobufTask

    def delay
      self.class.delay(serialize_to_string)
    end

  end
end
