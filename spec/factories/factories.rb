FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "yoda#{n}@dagobah.com" }
    first "Yoda"
    last "the Great One"
    password "foobar16"
  end

  factory :project do
    title "The first project"
    description "A very good project"
  end

  factory :collaboratorship do
    trait :collaborator_user do
      association :collaborator, factory: :user
    end

    trait :collaboratable_project do
      association :collaboratable, factory: :project
    end

    factory :user_project_collaboration, traits: [:collaborator_user, :collaboratable_project]
  end
end
