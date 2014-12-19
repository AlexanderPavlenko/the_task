module Services
  module Company
    class UpdateJobEndDate

      def call(job:, end_date:)
        Job.transaction do
          job.update! end_date: end_date
          job.handle_due_amount_change!
        end
        job
      end
    end
  end
end
