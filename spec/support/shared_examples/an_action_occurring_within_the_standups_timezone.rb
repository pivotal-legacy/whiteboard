shared_examples_for "an action occurring within the standup's timezone" do
  let(:time_zone_name) { double(:time_zone_name) }
  let(:standup) { double(:standup, time_zone_name: time_zone_name).as_null_object }

  before do
    allow(Standup).to receive(:find_by).and_return(standup)
    allow(Standup).to receive(:find).and_return(standup)
  end

  specify do
    expect(Time).to receive(:use_zone).with(time_zone_name)
  end
end
