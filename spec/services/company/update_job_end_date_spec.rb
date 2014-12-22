require 'spec_helper'

describe Services::Company::UpdateJobEndDate do

  before do
    @ic = Invoice.count
    @rc = Refund.count
  end

  it 'allows company to estimate a job creating invoice' do
    @job = create(:accepted_job)
    @end_date = Date.today + 1.day

    expect {
      Services::Company::UpdateJobEndDate.new.call(job: @job, end_date: @end_date)
    }.to change { [Invoice, Refund].map(&:count) }.from([@ic, @rc]).to([@ic+1, @rc])
    expect(@job.reload.end_date).to eq @end_date
  end

  it 'allows company to re-estimate a job creating new invoice or refund' do
    @job = create(:estimated_job)
    @client = @job.client
    @client.update_attribute(:local_account_amount, 1e10)
    @end_date = @job.end_date + 2.days

    expect {
      @job = Services::Company::UpdateJobEndDate.new.call(job: @job, end_date: @end_date)
    }.to change { [Invoice, Refund].map(&:count) }.from([@ic, @rc]).to([@ic+1, @rc])
    expect(@job.reload.end_date).to eq @end_date
    expect(@job.invoices.pending.count).to eq 1
    expect(@job.invoices.paid.count).to eq 0
    expect(@job.invoices.canceled.count).to eq 0

    @end_date = @end_date - 1.day

    expect {
      @job = Services::Company::UpdateJobEndDate.new.call(job: @job, end_date: @end_date)
    }.to change { [Invoice, Refund].map(&:count) }.from([@ic+1, @rc]).to([@ic+2, @rc])
    expect(@job.reload.end_date).to eq @end_date
    expect(@job.invoices.pending.count).to eq 1
    expect(@job.invoices.paid.count).to eq 0
    expect(@job.invoices.canceled.count).to eq 1

    @job.invoices.pending.last.pay_from_client_local_account!
    @end_date = @end_date - 1.day

    expect {
      @job = Services::Company::UpdateJobEndDate.new.call(job: @job, end_date: @end_date)
    }.to change { [Invoice, Refund].map(&:count) }.from([@ic+2, @rc]).to([@ic+2, @rc+1])
    expect(@job.reload.end_date).to eq @end_date
    expect(@job.invoices.pending.count).to eq 0
    expect(@job.invoices.paid.count).to eq 1
    expect(@job.invoices.canceled.count).to eq 1
  end
end
