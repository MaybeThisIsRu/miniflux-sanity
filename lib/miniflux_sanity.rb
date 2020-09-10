require "date"
require_relative "config"
require_relative "miniflux_api"
require_relative "utils/cache"
require_relative "utils/date"

class MinifluxSanity
	def initialize
		# Load env
		@@config = Config.new
		@@config.load_env

		# Set up miniflux and cache clients
		@@miniflux_client = MinifluxApi.new token: ENV["MINIFLUX_TOKEN"]
		@@cache_client = Cache.new path: "cache.json"
	end

	def last_fetched_today?
		if @@cache_client.last_fetched.nil?
			false
		else
			Date.parse(@@cache_client.last_fetched) == Date.today
		end
	end

	def is_older_than_before?(published_at:, before:)
		if Date.parse().to_time.to_i > DateUtils.get_before_timestamp(before: before)
			false
		else
			true
		end
	end
	
	def fetch_entries
		if self.last_fetched_today?
			p "Last run was today, skipping fetch."
		else
			p "Now collecting all unread entries before the specified date."
		end

		# We get these in blocks of 250
		# When we hit <250, we stop because that is the last call to make!
		size = 0
		limit = 250
		count = limit
		until count < limit or self.last_fetched_today? do

			entries = @@miniflux_client.get_entries before: ENV["MARK_READ_BEFORE"], offset: size, limit: limit
		
			entries.filter do |entry|
				# Just for some extra resilience, we make sure to check the published_at date before we filter it. This would be helpful where the Miniflux API itself has a bug with its before filter, for example.
				unless is_older_than_before? published_at: entry["published_at"], before: ENV["MARK_READ_BEFORE"]
					true
				else
					false
				end
			end
		
			count = entries.count
			size = size + count
			p "Fetched #{size} entries."
		
			@@cache_client.last_fetched = Date.today.to_s
			@@cache_client.size = size
			@@cache_client.add_entries_to_file data: entries
		
			unless count < limit
				p "Fetching more..."
			end
		end
	end

	def mark_entries_as_read
		start = 0
		interval = 10
		cached_data = @@cache_client.read_from_file

		while @@cache_client.size != 0 do
			stop = start + interval

			# For every 10 entries, mark as read.
			# Reduce size and remove entries accordingly in our file.
			filtered_data = cached_data["data"][start...stop]
			
			ids_to_mark_read = filtered_data.map { |entry| entry["id"] }

			@@miniflux_client.mark_entries_read ids: ids_to_mark_read

			@@cache_client.size -= interval
			@@cache_client.remove_entries_from_file ids: ids_to_mark_read

			start += interval

			p "#{@@cache_client.size} entries left to be mark as read."
		end
	end
end
