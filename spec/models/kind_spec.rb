require 'spec_helper'

describe Kind do
  before do
    @kind = Kind.new "Bummers", "Things we found that were upsetting"
  end
  it "has a name" do
    @kind.name.should == "Bummers"
  end

  it "has a subtitle" do
    @kind.subtitle.should == "Things we found that were upsetting"
  end
end