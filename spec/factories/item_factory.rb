FactoryGirl.define do
  factory :item do
    title "Focused specs are broken"
    kind "Help"
    date Date.today

    association :standup
  end

  factory :event, parent: :item, class: Event do
    kind "Event"
  end

  factory :help, parent: :item, class: Help do
    kind "Help"
  end

  factory :interesting, parent: :item, class: Interesting do
    kind "Interesting"
  end

  factory :new_face, parent: :item, class: NewFace do
    title "John"
    kind "NewFace"
  end
end
