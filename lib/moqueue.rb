unless defined?(MOQUEUE_ROOT)
  MOQUEUE_ROOT = File.dirname(__FILE__) + "/"
end
require MOQUEUE_ROOT + "moqueue/fibers18"

require MOQUEUE_ROOT + "moqueue/mock_exchange"
require MOQUEUE_ROOT + "moqueue/mock_session"
require MOQUEUE_ROOT + "moqueue/mock_queue"
require MOQUEUE_ROOT + "moqueue/mock_headers"
require MOQUEUE_ROOT + "moqueue/mock_broker"

require MOQUEUE_ROOT + "moqueue/object_methods"
require MOQUEUE_ROOT + "moqueue/matchers"

module Moqueue
end