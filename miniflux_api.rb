require "httparty"
require "date"
require_relative "hash"
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

	def get_entries(before:, limit: 100, offset:, status: 'unread', direction: 'asc')
		before = self.get_before_timestamp before: before

		begin
			custom_options = @options.deep_merge({
				:query => {
					:status => status,
					:direction => direction,
					:before => before,
					:offset => offset,
					:limit => limit
				}
			})
			response = self.class.get("/entries", custom_options)
			response.parsed_response["entries"]
		rescue
			p "Could not get entries from your Miniflux server."
		end
	end
end