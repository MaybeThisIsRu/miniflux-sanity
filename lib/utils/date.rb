module DateUtils
	def get_before_timestamp(before:)
		# If no days specified, default to 30 days.
		if before.nil?
			before = (Date.today - 30).to_time.to_i
		else
			before = (Date.today - before.to_i).to_time.to_i
		end
	end
	module_function :get_before_timestamp
end