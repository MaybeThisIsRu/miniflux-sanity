require "date"
require_relative "config"
require_relative "miniflux_api"
require_relative "utils/cache"

class MinifluxSanity
	def initialize(token:, host:, days:)
		# Configuration object
		# TODO Is there a way to pass this cleanly? We're passing everything we receive, with the exact same argument names as well
		@@config = Config.new token: token, host: host, days: days

		# Set up miniflux and cache clients
		@@miniflux_client = MinifluxApi.new host: host, token: @@config.auth[:token]
		@@cache_client = Cache.new path: "cache.json"
	end

	def last_fetched_today?
		if @@cache_client.last_fetched.nil?
			false
		else
			Date.parse(@@cache_client.last_fetched.to_s) == Date.today
		end
	end

	def is_older_than_cutoff?(published_at:)
		if Date.parse(published_at).to_time.to_i > @@config.cutoff_timestamp
			false
		else
			true
		end
	end
	
	def fetch_entries
		if self.last_fetched_today?
			puts "Last run was today, skipping fetch."
			exit
		else
			puts "Now collecting all unread entries before the specified date."
		end

		# We get these in blocks of 250
		# When we hit <250, we stop because that is the last call to make!
		size = 0
		limit = 250
		count = limit
		until count < limit do

			entries = @@miniflux_client.get_entries before: @@config.cutoff_timestamp, offset: size, limit: limit

			if entries.length < 1
				puts "No more new entries"
				exit true
			end
		
			# TODO This *should* be a bang-style method based on how Ruby is written. It should modify the entries list itself. Probably if we modeled an Entry and Entries... we could add this as a method on the Entries Model.
			entries = self.filter_before_cutoff entries: entries
		
			count = entries.count
			size = size + count
			puts "Fetched #{size} entries."
		
			@@cache_client.last_fetched = Date.today.to_s
			@@cache_client.size = size
			@@cache_client.add_entries_to_file data: entries
		
			unless count < limit
				puts "Fetching more..."
			end
		end
	end

	def filter_before_cutoff(entries:)
		# Just for some extra resilience, we make sure to check the published_at date before we filter it. This would be helpful where the Miniflux API itself has a bug with its before filter, for example.
		entries.filter { |entry| is_older_than_cutoff? published_at: entry["published_at"] }
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

			puts "#{@@cache_client.size} entries left to be mark as read."
		end
	end
end
