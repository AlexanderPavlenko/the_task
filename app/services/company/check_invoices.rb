module Services
  module Company
    class CheckInvoices

      # NOTE: As invoices are immutable, it looks like we should call `invoice.job.send_invoice!`
      #       on daily basis (or on demand just before paying) for each overdue invoice
      #       in order to update its amount with respect to the overdue_amount increase
      def call
        Invoice.check_for_overdue!
      end
    end
  end
end
