require "date"

require_relative "config"
config = Config.new
config.load_env

require_relative "miniflux_api"

require_relative "utils/cache"
require_relative "utils/date"

# https://bloggie.io/posts/how-to-fix-ruby-2-7-warning-using-the-last-argument-as-keyword-parameters-is-deprecated
# miniflux = MinifluxApi.new(**{ :token => ENV["MINIFLUX_TOKEN"] })
miniflux = MinifluxApi.new token: ENV["MINIFLUX_TOKEN"]

# We get these in blocks of 250
# When we hit <250, we stop because that is the last call to make!
size = 0
limit = 250
count = limit

cache_client = Cache.new path: "cache.json"
cache_last_fetched_today = cache_client.last_fetched.nil? ? false : Date.parse(cache_client.last_fetched) == Date.today

if cache_last_fetched_today
	p "Last run was today, skipping fetch."
else
	p "Now collecting all unread entries before the specified date."
end

until count < limit or cache_last_fetched_today do

	entries = miniflux.get_entries before: ENV["MARK_READ_BEFORE"], offset: size, limit: limit

	entries.filter do |entry|
		# Just for some extra resilience, we make sure to check the published_at date before we filter it. This would be helpful where the Miniflux API itself has a bug with its before filter, for example.
		unless Date.parse(entry["published_at"]).to_time.to_i > DateUtils.get_before_timestamp(before: ENV["MARK_READ_BEFORE"])
			true
		else
			false
		end
	end

	count = entries.count
	size = size + count
	p "Fetched #{size} entries."

	cache_client.last_fetched = Date.today.to_s
	cache_client.size = size
	cache_client.add_entries_to_file data: entries

	unless count < limit
		p "Fetching more..."
	end
end

