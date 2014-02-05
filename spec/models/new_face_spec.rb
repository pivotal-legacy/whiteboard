require "spec_helper"

describe NewFace do
  it "is valid with a date in the future" do
    new_face = create(:new_face, date: Date.tomorrow)

    expect(new_face).to be_valid
  end
end
