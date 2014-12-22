module Services
  module Client
    class CreateJob

      def call(client:, start_date:, client_rate:)
        Job.create(
          client: client,
          start_date: start_date,
          client_rate: client_rate,
        )
      end
    end
  end
end
