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

  factory :workspace do
    name "The first workspace"
  end

  factory :collaboratorship do
    trait :collaborator_user do
      association :collaborator, factory: :user
    end

    trait :collaboratable_project do
      association :collaboratable, factory: :project
    end

    trait :active do
      state "active"
    end

    trait :pending do
      state "pending"
    end

    trait :collaborator do
      role "collaborator"
    end

    trait :owner do
      role "owner"
    end

    factory :user_project_ownership, traits: [:collaborator_user, 
                                              :collaboratable_project,
                                              :active,
                                              :owner]

    factory :user_project_collaboration, traits: [:collaborator_user, 
                                                  :collaboratable_project,
                                                  :active,
                                                  :collaborator]

    factory :pending_user_project_collaboration, traits: [:collaborator_user, 
                                                          :collaboratable_project,
                                                          :pending,
                                                          :collaborator]
  end
end
