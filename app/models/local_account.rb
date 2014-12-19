class LocalAccount

  def initialize(owner:)
    @owner = owner
  end

  def balance
    @owner.reload.local_account_amount
  end

  def update_balance!(amount)
    if amount > 0
      @owner.update!("local_account_amount = local_account_amount + ?", amount)
    elsif amount < 0
      @owner.update!("local_account_amount = local_account_amount - ?", amount)
    end
  end

  def can_pay?(amount)
    balance >= amount
  end
end
