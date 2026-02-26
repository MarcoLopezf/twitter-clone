FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    username { Faker::Internet.unique.username(specifier: 3..30) }
    display_name { Faker::Name.name }
    password { "Password1!" }
    bio { Faker::Lorem.sentence(word_count: 10) }
    avatar_url { Faker::Internet.url }
  end
end
