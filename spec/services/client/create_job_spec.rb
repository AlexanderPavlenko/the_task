require 'spec_helper'

describe Services::Client::CreateJob do

  before do
    @start_date = Date.today + rand(1..30).days
    @client_rate = rand(10..100)
  end

  it 'allows client to create a new job' do
    @client = create(:client)

    expect {
      @job = Services::Client::CreateJob.new.call(client: @client, start_date: @start_date, client_rate: @client_rate)
    }.to change { Job.count }.by 1
    expect(
      Job.where(client_id: @client, start_date: @start_date, client_rate: @client_rate).count
    ).to eq 1
  end

  it 'does not allow to create a new job for a client with the overdue invoices' do
    @invoice = create(:overdue_invoice)
    @client = @invoice.job.client

    expect {
      @job = Services::Client::CreateJob.new.call(client: @client, start_date: @start_date, client_rate: @client_rate)
    }.to change { Job.count }.by 0
    expect(
      @job.errors[:client][0].include? 'overdue_invoices_are_present'
    ).to eq true
  end
end
