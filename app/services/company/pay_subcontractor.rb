module Services
  module Company
    class PaySubcontractor

      def call(job:)
        SubcontractorPayout.create!(job: job)
      end
    end
  end
end
