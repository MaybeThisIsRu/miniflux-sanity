class Config
	def load_env
		require 'dotenv'
		begin
			Dotenv.load
			rescue
			p 'Could not load environment variables.'
			exit(false)
		end
	end

	def cutoff_date
		require 'date'
		Date.today - ENV['MARK_READ_BEFORE'].to_i
	end 
end