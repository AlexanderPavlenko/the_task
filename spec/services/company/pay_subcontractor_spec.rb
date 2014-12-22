require 'spec_helper'

describe Services::Company::PaySubcontractor do

  it 'allows company to pay to subcontractor' do
    @job = create(:ended_job)
    @subcontractor = @job.subcontractor
    @subcontractor_balance = @subcontractor.local_account.balance

    expect {
      @payout = Services::Company::PaySubcontractor.new.call(job: @job)
    }.to(
      change { LocalAccountTransaction.count }.by 1
    )
    expect(
      @subcontractor.local_account.balance
    ).to eq(@subcontractor_balance + @payout.amount)
  end

  it 'does not allow company to pay for not ended job' do
    @job = create(:estimated_job)

    expect {
      @payout = Services::Company::PaySubcontractor.new.call(job: @job)
    }.to(
      change { LocalAccountTransaction.count }.by 0
    )
    expect(@payout.persisted?).to eq false
    expect(
      @payout.errors[:job][0].include? 'job_is_not_ended'
    ).to eq true
  end
end
