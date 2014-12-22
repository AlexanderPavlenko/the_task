require 'spec_helper'

describe Services::Client::PayForInvoice do

  it 'allows client to pay for invoice' do
    @invoice = create(:invoice)
    @client = @invoice.job.client

    @client.update_attributes! local_account_amount: @invoice.amount - 0.01

    expect {
      Services::Client::PayForInvoice.new.call invoice: @invoice
    }.to raise_exception(Invoice::NotEnoughFundsError)

    @client.update_attributes! local_account_amount: @invoice.amount

    expect {
      Services::Client::PayForInvoice.new.call invoice: @invoice
    }.to(
      change { LocalAccountTransaction.count }.by 1
    )
    expect(
      @client.reload.local_account_amount
    ).to eq 0
    expect(
      @invoice.reload.state
    ).to eq Invoice::PAID
  end
end
