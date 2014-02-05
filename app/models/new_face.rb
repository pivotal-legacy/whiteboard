class NewFace < Item
  validate :face_is_in_the_future

  private
  def face_is_in_the_future
    if (date || Time.at(0)).to_time < Time.now.beginning_of_day
      errors.add(:base, "Please choose a date in present or future")
    end
  end
end
