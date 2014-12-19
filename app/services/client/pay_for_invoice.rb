module Services
  module Client
    class PayForInvoice

      def call(invoice:)
        invoice.pay_from_client_local_account!
      end
    end
  end
end
