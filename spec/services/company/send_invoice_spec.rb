require 'spec_helper'

describe Services::Company::SendInvoice do

  it 'allows company to send an invoice' do
    @job = create(:estimated_job)

    expect {
      @invoice = Services::Company::SendInvoice.new.call(job: @job)
    }.to change { Invoice.count }.by 1
    expect(@invoice.state).to eq Invoice::PENDING
    expect(@invoice.amount).to eq @job.invoice_amount
  end
end
