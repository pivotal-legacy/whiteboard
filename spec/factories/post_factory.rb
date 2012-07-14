FactoryGirl.define do
  factory :post do
    title "Standup 12/12/12"
    standup { FactoryGirl.build(:standup) }
  end
end
