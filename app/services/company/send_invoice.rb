module Services
  module Company
    class SendInvoice

      def call(job:)
        job.send_invoice!
      end
    end
  end
end
