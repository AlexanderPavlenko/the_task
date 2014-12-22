class Client < ActiveRecord::Base
  has_many :jobs
  has_many :invoices, through: :jobs

  def local_account
    LocalAccount.new(owner: self)
  end
end
