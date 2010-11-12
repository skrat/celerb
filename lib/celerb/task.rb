module Celerb
  # Mixin for Celery tasks
  module Task

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def task_name(value)
        @@name = value
      end

      def delay(*args)
        argz = args.select{|a| !a.kind_of? Hash}
        kwargz = args.select{|a| a.kind_of? Hash}.first
        if argz.length + (kwargz && 1 || 0) > args.length
          raise "Wrong arguments, must be list followed by optional Hash"
        end
        TaskPublisher.delay_task(
          @@name, task_args=argz, task_kwargs=kwargz||{})
      end
    end

  end
end
