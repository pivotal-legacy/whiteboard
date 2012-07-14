require 'spec_helper'

describe Item do
  let(:item) { build_stubbed(:item) }

  describe "associations" do
    it { should belong_to(:post) }
    it { should belong_to(:standup) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
  end

  describe "kind" do
    describe "should allow valid kinds - " do
      ['New face', 'Help', 'Interesting'].each do |kind|
        it kind do
          item.kind = kind
          item.should be_valid
        end
      end
    end

    it "should not allow other kinds" do
      item.kind = "foobar"
      item.should_not be_valid
    end
  end

  describe "defaults" do
    it "defaults public to false" do
      Item.new.public.should == false
    end
  end
end
