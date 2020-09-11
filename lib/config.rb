class Config
	attr_reader :cutoff_date, :cutoff_timestamp, :auth

	def initialize(host:, token:, days:)
		require 'date'
		@cutoff_date = Date.today - days.to_i
		@cutoff_timestamp = @cutoff_date.to_time.to_i
		@auth = {
			:host => host,
			:token => token
		}
	end
end