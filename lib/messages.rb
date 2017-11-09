module Messages
  PositionAcquired = Struct.new(:price)
  PriceUpdated = Struct.new(:price)
  ThresholdUpdated = Struct.new(:price)
  RemoveFrom10SecondWindow = Struct.new(:price)
  RemoveFrom15SecondWindow = Struct.new(:price)
  SendToMeIn = Struct.new(:seconds, :message)
  GetOffPosition = Struct.new(:whatever)
end
