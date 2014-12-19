class Client < ActiveRecord::Base
  has_many :invoices

  def local_account
    LocalAccount.new(owner: self)
  end
end
