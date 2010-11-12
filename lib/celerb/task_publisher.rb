module Celerb
  class TaskPublisher

    def self.connect(opts)
      @@exchange = MQ.direct(opts[:exchange],
        :key => opts[:key], :durable => true)
    end

    def self.delay_task(task_name, task_args=[], task_kwargs={},
                   task_id=nil, taskset_id=nil, expires=nil, eta=nil,
                   exchange=nil, exchange_type=nil, retries=0)
      task_id = task_id || TaskPublisher.uniq_id
      publish({
        :task => task_name,
        :id   => task_id,
        :args => task_args,
        :kwargs  => task_kwargs,
        :retries => retries,
        :eta     => eta,
        :expires => expires
      })
      return task_id
    end

    private

    def self.publish(body)
      @@exchange.publish MessagePack.pack(body), {
        :content_type => 'application/x-msgpack',
        :content_encoding => 'binary'
      }
    end


    def self.uniq_id
      return UUID.create_v4.to_s
    end

  end
end
