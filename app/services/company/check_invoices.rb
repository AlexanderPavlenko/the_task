module Services
  module Company
    class CheckInvoices

      def call
        Invoice.check_for_overdue!
      end
    end
  end
end
