class Bus
  attr_reader :published_messages, :queue

  def initialize
    @queue = Queue.new
    @published_messages = []
  end

  def publish(message)
    @queue.push(message)
    @published_messages.push(message)
  end

  def clear
    @queue.clear
    @published_messages.clear
  end
end
