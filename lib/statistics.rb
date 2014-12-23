module Statistics
  extend self

  def gross_sales
    Invoice.paid.sum(:amount)
  end

  def revenue
    gross_sales - SubcontractorPayout.sum(:amount)
  end

  def rejection_rate
    Job.rejected.count.to_f / Job.count
  end

  def predicted_revenue
    Float::INFINITY
  end

  def best_clients(top: 5, timeframe: default_timeframe)
    clients_with_revenue_impact(timeframe: timeframe).order('revenue_impact desc').limit(top)
  end

  # NOTE: clients with no paid invoices are the worst by definition and are omitted
  def worst_clients(top: 5, timeframe: default_timeframe)
    clients_with_revenue_impact(timeframe: timeframe).order('revenue_impact asc').limit(top)
  end

  def best_subcontractor(timeframe: default_timeframe)
    subcontractors_with_revenue_impact(timeframe: timeframe).order('revenue_impact desc').first
  end

  def worst_client(today: Date.today)
    clients_with_overdue_days(today: today).order('overdue_days desc').first
  end

  def default_timeframe
    Date.today.beginning_of_month .. Date.today + 1.day
  end

  # TODO: somehow handle case when there is a paid invoice but no subcontractor payout
  def clients_with_revenue_impact(timeframe:)
    Client.joins(:invoices).
      where(invoices: {paid_at: timeframe}).
      select('clients.*').
      select("(SUM(invoices.amount) - (#{
        SubcontractorPayout.joins(:job).
          where('jobs.client_id = clients.id').
          where(subcontractor_payouts: {created_at: timeframe}).
          select('SUM(subcontractor_payouts.amount)').to_sql
      })) as revenue_impact").
      group('clients.id')
  end

  def clients_with_overdue_days(today:)
    Client.joins(:invoices).
      where(Invoice.arel_table[:overdue_at].lt today).
      select('clients.*').
      select("SUM(julianday('#{today}') - julianday(invoices.overdue_at)) as overdue_days").
      group('clients.id')
  end

  def subcontractors_with_revenue_impact(timeframe:)
    Subcontractor.joins(:invoices).
      where(invoices: {paid_at: timeframe}).
      select('subcontractors.*').
      select("(SUM(invoices.amount) - (#{
        SubcontractorPayout.joins(:job).
          where('jobs.subcontractor_id = subcontractors.id').
          where(subcontractor_payouts: {created_at: timeframe}).
          select('SUM(subcontractor_payouts.amount)').to_sql
      })) as revenue_impact").
      group('subcontractors.id')
  end
end
