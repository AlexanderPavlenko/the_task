require 'spec_helper'

describe Statistics do

  before :each do
    10.times do
      create(:overdue_invoice)
      create(:subcontractor_payout, job: create(:paid_invoice).job)
    end
  end

  it 'selects top 5 best clients of the month' do
    @revenue_impact = {}
    @best = Client.all.sort_by { |client|
      @revenue_impact[client.id] = client.invoices.paid.where(paid_at: Statistics.default_timeframe).sum(:amount) -
        SubcontractorPayout.joins(:job).where(subcontractor_payouts: {created_at: Statistics.default_timeframe}).
          where(jobs: {client_id: client}).sum(:amount)
      -@revenue_impact[client.id]
    }[0, 5].map(&:id)

    @result = Statistics.best_clients
    expect(
      [@result.map(&:revenue_impact).map(&:to_f), @result.map(&:id)]
    ).to eq [@revenue_impact.values_at(*@best), @best]
  end

  it 'selects top 5 worst clients of the month' do
    @revenue_impact = {}
    @worst = Client.all.reject { |client|
      client.invoices.paid.count == 0
    }.sort_by { |client|
      @revenue_impact[client.id] = client.invoices.paid.where(paid_at: Statistics.default_timeframe).sum(:amount) -
        SubcontractorPayout.joins(:job).where(subcontractor_payouts: {created_at: Statistics.default_timeframe}).
          where(jobs: {client_id: client}).sum(:amount)
    }[0, 5].map(&:id)

    @result = Statistics.worst_clients
    expect(
      [@result.map(&:revenue_impact).map(&:to_f), @result.map(&:id)]
    ).to eq [@revenue_impact.values_at(*@worst), @worst]
  end

  it 'selects top subcontractor' do
    @best_revenue_impact = 0
    Subcontractor.find_each { |subcontractor|
      revenue_impact = subcontractor.invoices.paid.where(paid_at: Statistics.default_timeframe).sum(:amount) -
        subcontractor.subcontractor_payouts.where(created_at: Statistics.default_timeframe).sum(:amount)
      if revenue_impact > @best_revenue_impact
        @best_revenue_impact = revenue_impact
        @best = subcontractor
      end
    }
    @result = Statistics.best_subcontractor
    expect(
      [@result.revenue_impact, @result.id]
    ).to eq [@best_revenue_impact, @best.id]
  end

  it 'selects worst client by overdue days' do
    @today = Date.today
    @overdue_days = Hash.new { |h, k| h[k] = 0 }
    Invoice.overdue.where(Invoice.arel_table[:overdue_at].lt @today).includes(:client).find_each do |invoice|
      @overdue_days[invoice.client.id] += @today - invoice.overdue_at
    end
    @max_overdue_days = 0
    @overdue_days.each { |k, v|
      if v > @max_overdue_days
        @worst_id, @max_overdue_days = k, v
      end
    }
    @result = Statistics.worst_client(today: @today)
    expect(
      [@result.id, @result.overdue_days]
    ).to eq [@worst_id, @max_overdue_days]
  end
end
