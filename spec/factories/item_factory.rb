FactoryGirl.define do
  factory :item do
    title "Can't run focused specs"
    kind "Help"

    association :standup
  end
end
