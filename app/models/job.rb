class Job < ActiveRecord::Base
  belongs_to :client
  belongs_to :subcontractor
  has_many :invoices

  SubcontractorRequiredError = Class.new(StandardError)
  EndDateRequiredError = Class.new(StandardError)

  STATES = (1..2).to_a.freeze
  ACCEPTED = 1
  REJECTED = 2

  validates :client, presence: true
  validates :start_date, presence: true # , timeliness: {on_or_after: -> { Date.current }, type: :date}
  # validates :end_date, timeliness: {on_or_after: -> { start_date }, type: :date}, allow_blank: true
  validates :client_rate, presence: true, numericality: {greater_than: 0}
  validates :state, inclusion: STATES, allow_blank: true
  validate :overdue_invoices_absence
  validate :subcantractor_busyness

  scope :ended, -> { where(Job.arel_table[:end_date].lteq(Date.today)) }

  def ended?
    end_date && (end_date <= Date.today)
  end

  def reject!
    update_attributes!(state: REJECTED)
  end

  def due_amount
    raise EndDateRequiredError unless end_date
    client_rate * (end_date - start_date).days
  end

  def paid_amount
    invoices.paid.sum(:amount)
  end

  def overdue_amount
    raise EndDateRequiredError unless end_date
    overdue_days = (Date.today - end_date).days
    overdue_days > 0 ? client_rate * overdue_days : 0
  end

  def invoice_amount
    due_amount + overdue_amount - paid_amount
  end

  def refund_amount
    -invoice_amount
  end

  def subcontractor_payout_amount
    raise SubcontractorRequiredError unless subcontractor
    raise EndDateRequiredError unless end_date
    subcontractor.rate * (end_date - start_date).days
  end

  def send_invoice!(amount: invoice_amount)
    raise ArgumentError, "amount should be greater than 0" if amount <= 0
    Invoice.cancel_invoices(invoices.unpaid)
    Invoice.create!(job: self, amount: amount)
  end

  def send_refund!(amount: refund_amount)
    raise ArgumentError, "amount should be greater than 0" if amount <= 0
    Refund.create!(job: self, amount: amount)
  end

  def handle_due_amount_change!
    amount_difference = paid_amount - due_amount # NOTE: overdue is ignored
    if amount_difference > 0
      send_refund! amount: amount_difference
    elsif amount_difference < 0
      send_invoice! amount: -amount_difference
    end
  end

  def standard_discount
    # "Client may loose discount if one of their invoices is marked as overdue"
    # — but he cannot create new jobs, when one of their invoices is marked as overdue
    n, discount = Framework.app.config['discount_after_N_jobs']
    if client.jobs.ended.count >= n
      discount
    else
      0
    end
  end

  def overdue_invoices_absence
    if client && client.invoices.overdue.present?
      errors.add :client, :overdue_invoices_are_present
    end
  end

  def subcantractor_busyness
    if subcontractor && subcontractor.busy?
      errors.add :subcontractor, :subcontractor_is_busy
    end
  end
end
