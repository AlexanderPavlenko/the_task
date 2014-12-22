class LocalAccount

  attr_reader :owner

  def initialize(owner:)
    @owner = owner
  end

  def balance
    @owner.reload.local_account_amount
  end

  def update_balance!(amount)
    @owner.increment! :local_account_amount, amount
  end

  def can_pay?(amount)
    balance >= amount
  end
end
