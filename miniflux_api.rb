require "httparty"
require "date"
require_relative "utils/date"

class MinifluxApi
	include HTTParty
	base_uri "#{ENV["MINIFLUX_HOST"]}/v1/"

	include DateUtils

	def initialize(token:)
		@options = {
			:headers => {
				"X-Auth-Token": token,
				"Accept": "application/json"
			}
		}
	end

	def get_entries(before:, offset:, status: 'unread', direction: 'asc')
		before = self.get_before_timestamp before: before

		begin
			response = self.class.get("/entries?status=#{status.to_s}&direction=#{direction.to_s}&before=#{before.to_s}&offset=#{offset}", @options)
			response.parsed_response["entries"]
		rescue
			p "Could not get entries from your Miniflux server."
		end
	end
end