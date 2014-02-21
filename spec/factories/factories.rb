FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "yoda#{n}@dagobah.com" }
    first "Yoda"
    last "the Great One"
    password "foobar16"
  end
end
