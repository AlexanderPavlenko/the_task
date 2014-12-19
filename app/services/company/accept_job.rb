module Services
  module Company
    class AcceptJob

      def call(job:, subcontractor:, discount: nil)
        job.update!(subcontractor: subcontractor, discount: discount || job.standard_discount)
      end
    end
  end
end
