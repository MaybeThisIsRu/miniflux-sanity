require "minitest/autorun"
require "config"

class TestConfig < Minitest::Test
	def setup
		@config = Config.new host: "https://example.com/", token: "abcdef", days: 1
	end

	def test_must_return_cutoff_date
		Date.stub :today, Date.parse('2020-09-05') do
			# works here
			puts Date.today
			# doesn't work in invoked method
			assert_equal Date.parse('2020-09-04'), @config.cutoff_date
		end
	end

	# def test_must_return_cutoff_timestamp
	# end

	# def test_instance_has_auth_details
	# end
end