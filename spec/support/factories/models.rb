FactoryGirl.define do

  factory :client do
    sequence(:name) { |n| "client_#{n}" }
    local_account_amount { rand 0..10000 }
  end

  factory :job do
    client
    client_rate { rand 10..100 }
    start_date { Date.today - 1.day }

    factory :accepted_job do
      subcontractor
      state Job::ACCEPTED

      factory :estimated_job do
        end_date { Date.today + 1.day }
      end

      factory :ended_job do
        end_date { Date.today }
      end
    end

    factory :rejected_job do
      state Job::REJECTED
    end
  end

  factory :subcontractor do
    rate { rand 10..100 }
    local_account_amount { rand 0..10000 }
  end

  factory :invoice do
    job
    amount { rand 0..10000 }

    factory :overdue_invoice do
      association :job, factory: :ended_job
      state Invoice::OVERDUE
    end
  end

  factory :refund do
    job
    amount { rand 0..10000 }
  end

  factory :subcontractor_payout do
    job
    amount { rand 0..10000 }
  end
end
