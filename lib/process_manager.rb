require_relative 'bus'
require_relative 'messages'

class ProcessManager
  def initialize(bus)
    @bus = bus
    @done = false
  end

  def run
    loop do
      message = @bus.queue.pop
      process(message)
      break if done?
    end
  end

  def done?
    @done
  end

  def process(message)
    case message
    when Messages::PositionAcquired
      @threshold = message.price
      @window15 = []
      @window10 = []
    when Messages::PriceUpdated
      puts "Price updated to #{message.price}"
      @window15.push(message.price)
      @window10.push(message.price)

      @bus.publish(Messages::SendToMeIn.new(10, Messages::RemoveFrom10SecondWindow.new(message.price)))
      @bus.publish(Messages::SendToMeIn.new(15, Messages::RemoveFrom15SecondWindow.new(message.price)))
    when Messages::RemoveFrom15SecondWindow
      # puts "15s after #{message.price}"
      @window15.delete_at(@window15.find_index(message.price))
      if @window15.min > @threshold
        @threshold = @window15.min
        puts "Threshold updated: #{@threshold}"
        @bus.publish(Messages::ThresholdUpdated.new(@threshold))
      end
    when Messages::RemoveFrom10SecondWindow
      # puts "10s after #{message.price}"
      @window10.delete_at(@window10.find_index(message.price))
      if @window10.max < @threshold
        @done = true
        puts "Sell at #{@window10.last}!!"
        @bus.publish(Messages::GetOffPosition.new)
      end
    end
  end
end
