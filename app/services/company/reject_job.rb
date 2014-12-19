module Services
  module Company
    class RejectJob

      def call(job:)
        job.reject!
      end
    end
  end
end
