FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    published {
      r = rand(0..1)
      if r.zero?
        false
      else
        true
      end
    }
    association :user, factory: :user
  end
end
