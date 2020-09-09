require_relative "config"
config = Config.new
config.load_env

require_relative "miniflux_api"

require_relative "utils/cache"
require_relative "utils/date"

# https://bloggie.io/posts/how-to-fix-ruby-2-7-warning-using-the-last-argument-as-keyword-parameters-is-deprecated
# miniflux = MinifluxApi.new(**{ :token => ENV["MINIFLUX_TOKEN"] })
miniflux = MinifluxApi.new token: ENV["MINIFLUX_TOKEN"]

# We get these in blocks of 100
# When we hit <100, we stop because that is the last call to make!
p "Now collecting all unread entries before the specified date."

size = 0
count = 100

until count < 100 do
	entries = miniflux.get_entries before: ENV["MARK_READ_BEFORE"], offset: size

	entries.filter do |entry|
		# Just for some extra resilience, we make sure to check the published_at date before we filter it. This would be helpful where the Miniflux API itself has a bug with its before filter.
		unless Date.parse(entry["published_at"]).to_time.to_i > DateUtils.get_before_timestamp(before: ENV["MARK_READ_BEFORE"])
			true
		else
			false
		end
	end

	cache = Cache.new path: "cache.json"
	cache.write data: entries

	count = entries.count
	size = size + count
	message = "Have #{size} entries"
	p count < 100 ? message : message + " so far. Fetching more..."
end

