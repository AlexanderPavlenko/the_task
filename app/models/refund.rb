class Refund < ActiveRecord::Base
  belongs_to :job
  has_one :local_account_transaction, as: :transactionable

  validates :job, presence: true
  validates :amount, presence: true, numericality: {greater_than: 0}

  after_create :create_transaction!

  def create_transaction!
    LocalAccountTransaction.create!(
      transactionable: self,
      amount: amount,
      local_account: job.client.local_account,
    )
  end
end

