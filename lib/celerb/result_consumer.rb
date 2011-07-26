module Celerb
  class ResultConsumer

    def initialize channel, opts={}
      @channel = channel
      @options = opts
      @handlers = {}
      EM.add_periodic_timer(60) do
        now = Time.now
        @handlers.delete_if {|id,h| h[:expires] < now}
      end
    end

    def register(task_id, expiration, &blk)
      @handlers[task_id] = {
        :queue   => subscribe(task_id),
        :expires => Time.now + expiration,
        :proc    => blk
      }
    end

    def consume(header, body)
      result = Result.new(MessagePack.unpack(body))
      if @handlers.include? result.task_id
        handler = @handlers.delete result.task_id
        handler[:proc].call result
        handler[:queue].unsubscribe
      end
    end

    private

    def subscribe(task_id)
      task_id_to_queue(task_id).subscribe &method(:consume)
    end

    def task_id_to_queue(task_id)
      @channel.queue(task_id.delete('-'), :auto_delete => true,
        :arguments => (
          @options[:results_arguments] and
          Hash[@options[:results_arguments].map{|k, v| [k.to_s, v]}] or
          {}))
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
