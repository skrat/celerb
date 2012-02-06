module Celerb
  # Mixin for Celery tasks
  module Task

    def self.included(base)
      base.extend ClassMethods
      base.send :attr_accessor, :queue
    end

    # Sends task to celery worker
    def delay(q = self.queue)
      self.class.delay q, self.to_celery
    end

    # Should return valid arguments for task specified by #task_name
    def to_celery
      raise NotImplementedError, "You have to return Celery task arguments here"
    end

    module ClassMethods

      def task_name(value)
        @name = value
      end

      def delay(queue, args)
        argz = args.dup
        kwargz = {}
        if argz.last.kind_of? Hash
          kwargz = argz.pop
        end
        AsyncResult.new(TaskPublisher.delay_task(
          queue, @name, task_args=argz, task_kwargs=kwargz))
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
