FactoryGirl.define do
  factory :user do
    username         'Manuela'
    sequence(:email) { |n| "manuela#{n}@madrid.es" }
    password         'judgmentday'
    confirmed_at     { Time.now }

    trait :hidden do
      hidden_at Time.now
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.now
    end
  end

  factory :identity do
    user nil
    provider "Twitter"
    uid "MyString"
  end

  factory :residence do
    document_number  '12345678Z'
    document_type    1
    date_of_birth    Date.new(1980, 12, 31)
    postal_code      "28013"
  end

  factory :sms do
    phone "699999999"
  end

  factory :letter do
    user
    address
  end

  factory :address do
    street_type   "Calle"
    street        "Alcalá"
    number        "1"
  end

  factory :verified_user do
    document_number  '12345678Z'
    document_type    'dni'
  end

  factory :debate do
    sequence(:title)     { |n| "Debate #{n} title" }
    description          'Debate description'
    terms_of_service     '1'
    association :author, factory: :user

    trait :hidden do
      hidden_at Time.now
    end

    trait :with_ignored_flag do
      ignored_flag_at Time.now
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.now
    end

    trait :flagged do
      after :create do |debate|
        Flag.flag!(FactoryGirl.create(:user), debate)
      end
    end
  end

  factory :vote do
    association :votable, factory: :debate
    association :voter,   factory: :user
    vote_flag true
    after(:create) do |vote, _|
      vote.votable.update_cached_votes
    end
  end

  factory :comment do
    association :commentable, factory: :debate
    user
    body 'Comment body'

    trait :hidden do
      hidden_at Time.now
    end

    trait :with_ignored_flag do
      ignored_flag_at Time.now
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.now
    end

    trait :flagged do
      after :create do |debate|
        Flag.flag!(FactoryGirl.create(:user), debate)
      end
    end
  end

  factory :administrator do
    user
  end

  factory :moderator do
    user
  end

  factory :organization do
    user
    sequence(:name) { |n| "org#{n}" }

    trait :verified do
      verified_at Time.now
    end

    trait :rejected do
      rejected_at Time.now
    end
  end

  factory :tag, class: 'ActsAsTaggableOn::Tag' do
    sequence(:name) { |n| "Tag #{n} name" }

    trait :featured do
      featured true
    end

    trait :unfeatured do
      featured false
    end
  end

  factory :setting do
    sequence(:key) { |n| "setting key number #{n}" }
    sequence(:value) { |n| "setting number #{n} value" }
  end

  factory :ahoy_event, :class => Ahoy::Event do
    id { SecureRandom.uuid }
    time DateTime.now
    sequence(:name) {|n| "Event #{n} type"}
  end

  factory :visit  do
    id { SecureRandom.uuid }
    started_at DateTime.now
  end

end
