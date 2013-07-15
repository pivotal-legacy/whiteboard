class StandupPresenter < SimpleDelegator
  STANDUP_CLOSINGS = [
      "STRETCH!",
      "STRETCH! It's good for you!",
      "STRETCH!!!!!"
  ]

  def initialize(standup)
    @standup = standup
    __setobj__(standup)
  end

  def closing_message
    return @standup.closing_message if @standup.closing_message.present?
    return "STRETCH! It's Floor Friday!" if Date.today.wday == 5

    index = rand(STANDUP_CLOSINGS.length)
    STANDUP_CLOSINGS[index]
  end
end