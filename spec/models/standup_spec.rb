require 'spec_helper'

describe Standup do
  describe 'associations' do
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:posts).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:to_address) }
  end

  it 'has a closing message' do
    standup = FactoryGirl.create(:standup, closing_message: 'Yay')
    standup.closing_message.should == 'Yay'
  end
end
