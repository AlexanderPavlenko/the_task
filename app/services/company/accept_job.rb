module Services
  module Company
    class AcceptJob

      def call(job:, subcontractor:, discount: nil)
        job.update_attributes!(
          state: Job::ACCEPTED,
          subcontractor: subcontractor,
          discount: discount || job.standard_discount,
        )
      end
    end
  end
end
