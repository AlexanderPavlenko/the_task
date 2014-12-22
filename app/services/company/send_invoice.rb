module Services
  module Company
    class SendInvoice

      # NOTE: currently invoice for a new job is automatically sent by Services::Company::UpdateJobEndDate
      def call(job:)
        job.send_invoice!
      end
    end
  end
end
