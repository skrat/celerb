require File.dirname(__FILE__) + '/test_helper.rb'

class TestCelerb < Test::Unit::TestCase

  def test_unique_id
    assert !Celerb::TaskPublisher.uniq_id.nil?
  end

  def x_test_delay_task
    with_celery do |exchange|
      tp = Celerb::TaskPublisher.new exchange
      assert !tp.delay_task('some').nil?
    end
  end

  def test_task_class
    AMQP.run(TEST_CELERY[:AMQP]) do
      Celerb::TaskPublisher.connect(TEST_CELERY)
      asset = open(File.join(File.dirname(__FILE__), 'vleugel.kmz')).read()

      task = Floorplanner::ThumbTask.new(
        :type       => Floorplanner::ThumbTask::AssetType::DAE,
        :resultPath => '/test/thing/%s/some.png',
        :asset      => asset,
        :styles     => [Floorplanner::ThumbStyle.new(
          :name => 'original',
          :size => 512)]
      ).delay.wait(60) do |result|
        puts result.body
      end
      puts "Done..."
    end
  end

  private

  def with_amqp(&blk)
    AMQP.connect(TEST_CELERY[:AMQP])
    yield
  end

  def with_celery(&blk)
    with_amqp do
      yield MQ.direct(TEST_CELERY[:exchange],
        :key => TEST_CELERY[:key], :durable => true)
    end
  end

end
