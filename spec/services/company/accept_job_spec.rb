require 'spec_helper'

describe Services::Company::AcceptJob do

  it 'allows company to accept a job' do
    @job = create(:job)
    @subcontractor = create(:subcontractor)

    Services::Company::AcceptJob.new.call job: @job, subcontractor: @subcontractor
    expect(
      Job.where(id: @job, subcontractor_id: @subcontractor, state: Job::ACCEPTED, discount: @job.standard_discount).count
    ).to eq 1
  end

  it 'does not allow to accept a job with a busy subcontractor' do
    @job = create(:job)
    @subcontractor = create(:subcontractor)
    3.times { create(:job, subcontractor: @subcontractor) }

    expect {
      Services::Company::AcceptJob.new.call job: @job, subcontractor: @subcontractor
    }.to raise_exception ActiveRecord::RecordInvalid
    expect(
      @job.errors[:subcontractor][0].include? 'subcontractor_is_busy'
    ).to eq true
  end
end
