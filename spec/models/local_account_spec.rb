require 'spec_helper'

describe LocalAccount do

  before do
    @account = create(:client).local_account
  end

  it 'has balance' do
    expect(
      @account.balance
    ).to eq @account.owner.local_account_amount
  end

  it 'updates balance' do
    expect {
      @account.update_balance! 0.01
    }.to change { @account.balance }.by 0.01
    expect {
      @account.update_balance! -0.01
    }.to change { @account.balance }.by -0.01
  end

  it 'checks ability to pay' do
    @account.update_balance! 1
    expect(
      @account.can_pay? 1
    ).to eq true
  end
end
