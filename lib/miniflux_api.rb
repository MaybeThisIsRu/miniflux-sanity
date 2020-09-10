require "httparty"
require "date"
require_relative "hash"
require_relative "utils/date"

class MinifluxApi
	include HTTParty
	base_uri "#{ENV["MINIFLUX_HOST"]}/v1/"
	maintain_method_across_redirects true

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
		rescue => error
			p "Could not get entries from your Miniflux server. More details to follow.", error
			exit(false)
		end
	end

	# Pass in an array of IDs
	def mark_entries_read(ids:)
		new_options = @options.deep_merge({
			:headers => {
				"Content-Type": "application/json"
			},
			:body => {
				:entry_ids => ids,
				:status => "read"
			}.to_json
		})

		response = self.class.put("/entries", new_options)

		if response.code.to_i == 204
			p "Marked entries with ID #{ids.join ", "} as read."
		else
			p "Could not mark entries with ID #{ids.join ", "} as read"
			exit(false)
		end

	end
end