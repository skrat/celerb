module Celerb
  # Mixin for Celery tasks
  module Task

    def self.included(base)
      base.extend ClassMethods
    end

    def delay
      self.class.delay self.to_celery
    end

    def to_celery
      raise NotImplementedError, "You have to return Celery task arguments here"
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
        AsyncResult.new(TaskPublisher.delay_task(
          @@name, task_args=argz, task_kwargs=kwargz||{}))
      end
    end

  end

  class AsyncResult

    attr_reader :task_id

    def initialize(task_id)
      @task_id = task_id
    end

    def wait(&blk)
      TaskPublisher.register_result_handler(@task_id, &blk)
    end
  end
end
