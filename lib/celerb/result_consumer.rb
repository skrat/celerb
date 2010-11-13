module Celerb
  class ResultConsumer
    def initialize(opts)
      @exchange = MQ.direct(opts[:results], :auto_delete => true)
      @handlers = {}
      @queues = {}
    end

    def register(task_id, &blk)
      @handlers[task_id] = blk
    end

    def subscribe(task_id)
      queue = task_id_to_queue(task_id)
      queue.subscribe &method(:consume)
    end

    def consume(header, body)
      result = Result.new(MessagePack.unpack(body))
      queue  = @queues.delete result.task_id
      queue.unsubscribe
      if @handlers.include? result.task_id
        handler = @handlers.delete result.task_id
        handler.call result
      end
    end

    private

    def task_id_to_queue(task_id)
      queue = MQ.queue(task_id_to_queue_name(task_id), :auto_delete => true)
      queue.bind(@exchange)
      @queues[task_id] = queue
    end

    def task_id_to_queue_name(task_id)
      task_id.gsub('-', '')
    end
  end

  class Result

    attr_reader :task_id
    attr_reader :status
    attr_reader :body

    def initialize(message)
      @task_id = message['task_id']
      @status  = message['status'].to_sym
      @body    = message['result']
    end

    def success?
      @status == :SUCCESS
    end
  end
end
