require "httparty"
require "date"
require_relative "hash"
require_relative "utils/date"

class MinifluxApi
	include HTTParty
	maintain_method_across_redirects true

	def initialize(host:, token:)
		self.class.base_uri host

		@options = {
			:headers => {
				"X-Auth-Token": token,
				"Accept": "application/json"
			}
		}
	end

	def get_entries(before:, limit: 100, offset:, status: 'unread', direction: 'asc')
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
			response_code = response.code.to_i

			if response_code >= 400
				raise response.parsed_response
			else
				response.parsed_response["entries"]
			end
		rescue => error
			puts "Could not get entries from your Miniflux server. More details to follow.", error
			exit
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
			puts "Marked entries with ID #{ids.join ", "} as read."
		else
			puts "Could not mark entries with ID #{ids.join ", "} as read"
			exit(false)
		end

	end
end