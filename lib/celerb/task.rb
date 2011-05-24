module Celerb
  # Mixin for Celery tasks
  module Task

    def self.included(base)
      base.extend ClassMethods
    end

    # Sends task to celery worker
    def delay
      self.class.delay self.to_celery
    end

    # Should return valid arguments for task specified by #task_name
    def to_celery
      raise NotImplementedError, "You have to return Celery task arguments here"
    end

    module ClassMethods

      def task_name(value)
        @name = value
      end

      def delay(args)
        argz = args.dup
        kwargz = {}
        if argz.last.kind_of? Hash
          kwargz = argz.pop
        end
        AsyncResult.new(TaskPublisher.delay_task(
          @name, task_args=argz, task_kwargs=kwargz))
      end
    end

  end

  class AsyncResult

    attr_reader :task_id

    def initialize(task_id)
      @task_id = task_id
    end

    # Awaits a task result and calls block when the result is available.
    # Expiration needs to be explicitly specified in seconds to prevent memory
    # leaks. Result handlers are periodically checked and expired ones are deleted.
    def wait(expiration, &blk)
      TaskPublisher.register_result_handler(@task_id, expiration, &blk)
    end
  end
end
