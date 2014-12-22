class SubcontractorPayout < ActiveRecord::Base
  belongs_to :job
  has_one :local_account_transaction, as: :transactionable

  before_validation do
    self.amount ||= job.subcontractor_payout_amount if job && job.ended?
  end

  validates :job, presence: true
  validates :amount, presence: true, numericality: {greater_than: 0}
  validate :job_completeness

  after_create :create_transaction!

  def create_transaction!
    LocalAccountTransaction.create!(
      transactionable: self,
      amount: amount,
      local_account: job.subcontractor.local_account,
    )
  end

  def job_completeness
    unless job.ended?
      errors.add :job, :job_is_not_ended
    end
  end
end
