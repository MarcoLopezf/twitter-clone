FactoryBot.define do
  factory :tweet do
    content { Faker::Lorem.sentence(word_count: 10) }
    association :user
  end
end
