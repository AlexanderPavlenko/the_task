FactoryGirl.define do

  factory :client do
    sequence(:name) { |n| "client_#{n}" }
    local_account_amount { rand 0..10000 }
  end

  factory :job do
    client
    client_rate { rand 10..100 }
    start_date { Date.today - rand(1..30).days }

    factory :accepted_job do
      after :build do |job|
        job.subcontractor.rate = rand(10..job.client_rate)
      end

      subcontractor
      state Job::ACCEPTED

      factory :estimated_job do
        end_date { Date.today + rand(1..30).day }
      end

      factory :ended_job do
        end_date { rand(@instance.start_date + 1.day .. Date.today) }
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
    association :job, factory: :estimated_job
    amount { @instance.job.invoice_amount }

    factory :overdue_invoice do
      association :job, factory: :ended_job
      state Invoice::OVERDUE
      overdue_at { @instance.job.end_date }
    end

    factory :paid_invoice do
      association :job, factory: :ended_job
      state Invoice::PAID
      paid_at { Time.now }
    end
  end

  factory :refund do
    association :job, factory: :estimated_job
    amount { rand 0..10000 }
  end

  factory :subcontractor_payout do
    association :job, factory: :ended_job
    amount { rand 0..10000 }
  end
end
