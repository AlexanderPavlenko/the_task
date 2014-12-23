require 'spec_helper'

describe Services::Company::CheckInvoices do

  it 'detects overdue invoices' do
    @job = create(:ended_job)
    @invoice = create(:invoice, job: @job)
    expect(@invoice.state).to eq Invoice::PENDING
    Services::Company::CheckInvoices.new.call
    @invoice.reload
    expect(@invoice.state).to eq Invoice::OVERDUE
    expect(@invoice.overdue_at).to eq @job.end_date
  end
end
