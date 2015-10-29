require 'rails_helper'

describe Kind do
  before do
    @kind = Kind.new "Bummers", "Things we found that were upsetting"
  end
  it "has a name" do
    expect(@kind.name).to eq "Bummers"
  end

  it "has a subtitle" do
    expect(@kind.subtitle).to eq "Things we found that were upsetting"
  end
end
