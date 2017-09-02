FactoryGirl.define do
  sequence(:email) do |n|
    "user#{n}@test.com"
  end
  sequence(:firstname) do |n|
    "Firstname #{n}"
  end
  sequence(:lastname) do |n|
    "Lastname #{n}"
  end
  factory :user do
    email
    password "123456789"
    firstname
    lastname
    confirmed_at Time.now
  end
end
