class Subcontractor < ActiveRecord::Base
  has_many :jobs
  has_many :invoices, through: :jobs
  has_many :subcontractor_payouts, through: :jobs

  scope :busy, -> {
    # TODO: joins-group-having for more than 3 jobs
  }

  def busy?
    jobs.count >= 3
  end

  def local_account
    LocalAccount.new(owner: self)
  end
end
