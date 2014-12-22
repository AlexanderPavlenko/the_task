class Invoice < ActiveRecord::Base
  belongs_to :job
  has_one :local_account_transaction, as: :transactionable

  STATES = (1..4).to_a.freeze
  PENDING = 1
  OVERDUE = 2
  PAID = 3
  CANCELED = 4

  NotEnoughFundsError = Class.new(StandardError)

  before_validation do
    self.state ||= PENDING
  end

  validates :job, presence: true
  validates :amount, presence: true, numericality: {greater_than: 0}
  validates :state, presence: true, inclusion: STATES

  scope :paid, -> { where(state: PAID) }
  scope :unpaid, -> { where(state: [PENDING, OVERDUE]) }
  scope :pending, -> { where(state: PENDING) }
  scope :overdue, -> { where(state: OVERDUE) }
  scope :canceled, -> { where(state: CANCELED) }

  def pay_from_client_local_account!
    local_account = job.client.local_account
    # TODO: lock account balance
    unless local_account.can_pay?(amount)
      raise NotEnoughFundsError
    end
    Invoice.transaction do
      update_attributes! state: PAID
      LocalAccountTransaction.create!(
        transactionable: self,
        amount: -amount,
        local_account: local_account,
      )
    end
  end

  def self.cancel_invoices(relation)
    relation.update_all state: Invoice::CANCELED
  end

  def self.check_for_overdue!
    pending.where(job_id: Job.ended).find_each do |invoice|
      invoice.update_attributes! state: OVERDUE
    end
  end
end
