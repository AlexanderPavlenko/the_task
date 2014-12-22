require 'spec_helper'

describe Services::Company::RejectJob do

  it 'allows company to reject a job' do
    @job = create(:job)

    Services::Company::RejectJob.new.call(job: @job)
    expect(@job.reload.state).to eq Job::REJECTED
  end
end
