require 'bus'
require 'process_manager'

describe ProcessManager do
  let(:bus) { Bus.new }

  let(:process_manager) { ProcessManager.new(bus) }

  before do
    process_manager.process(Messages::PositionAcquired.new(100))
    bus.clear
  end

  describe 'price increases for 15s' do
    let(:price_updates) { [101, 102, 105, 106] }

    before do
      price_updates.each do |price|
        process_manager.process(Messages::PriceUpdated.new(price))
      end
    end

    describe '15s after first update' do
      it 'updates the threshold' do
        process_manager.process(Messages::RemoveFrom15SecondWindow.new(101))

        expect(bus.published_messages)
          .to include(Messages::ThresholdUpdated.new(102))
      end
    end
  end

  describe 'price falls for 10s' do
    let(:price_updates) { [99, 97, 96, 95, 94] }

    before do
      price_updates.each do |price|
        process_manager.process(Messages::PriceUpdated.new(price))
      end
      bus.clear
    end

    describe '10s after first update' do
      it 'gets off the position' do
        process_manager.process(Messages::RemoveFrom10SecondWindow.new(99))

        expect(bus.published_messages).to include(Messages::GetOffPosition.new)
      end
    end
  end

  describe 'price keeps falling' do
    let(:price_updates) { [99, 97, 96, 95, 94] }

    before do
      price_updates.each do |price|
        process_manager.process(Messages::PriceUpdated.new(price))
      end
      process_manager.process(Messages::RemoveFrom10SecondWindow.new(99))
      process_manager.process(Messages::PriceUpdated.new(90))
      bus.clear
    end

    describe '10s after first update' do
      it 'gets off the position' do
        process_manager.process(Messages::RemoveFrom10SecondWindow.new(97))

        expect(bus.published_messages).to be_empty
      end
    end
  end

  describe 'price fluctuates' do
    let(:price_updates) { [99, 97, 96, 104, 105] }

    before do
      price_updates.each do |price|
        process_manager.process(Messages::PriceUpdated.new(price))
      end
      bus.clear
    end

    describe '10s after first update' do
      it 'does not get off position' do
        process_manager.process(Messages::RemoveFrom10SecondWindow.new(99))

        expect(bus.published_messages).to be_empty
      end
    end

    describe '15s after first update' do
      it 'does not change the threshold' do
        process_manager.process(Messages::RemoveFrom15SecondWindow.new(99))

        expect(bus.published_messages).to be_empty
      end
    end
  end
end
