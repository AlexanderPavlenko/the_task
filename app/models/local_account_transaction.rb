class LocalAccountTransaction < ActiveRecord::Base
  belongs_to :transactionable, polymorphic: true

  attr_accessor :local_account

  validates :transactionable, presence: true
  validates :amount, presence: true, numericality: true
  validates :local_account_amount_before, presence: true, numericality: true

  before_validation do
    self.local_account_amount_before = local_account.balance
  end

  after_create :update_local_account_balance!

  def update_local_account_balance!
    local_account.update_balance!(amount)
  end
end
