require 'stringio'
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/celerb'
require 'test/thumbTask.pb'

TEST_CELERY = {
  :AMQP => {
    :host  => 'localhost',
    :user  => 'geri',
    :pass  => 'geri',
    :vhost => 'geri'
  },
  :key   => 'celery',
  :exchange => 'celery',
  :results  => 'celeryresults'
}

