FactoryGirl.define do
  factory :standup do
    title { Faker::Company.name }
    to_address { Faker::Internet.email }
  end
end
