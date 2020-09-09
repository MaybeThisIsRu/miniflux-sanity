require "json"

class Cache
	def initialize(path:)
		@config = {
			:path => path
		}
	end

	def read
		if File.readable? @config[:path]
			JSON.parse(File.read(@config[:path]).to_s)
		else
			Array.new
		end
	end

	def write(data:)
		cache = self.read
		data.each do |new_entry|
			unless cache.find_index { |cache_entry| cache_entry["id"] == new_entry["id"] }
				cache.push new_entry
			end
		end
		File.write(@config[:path], cache.to_json)
	end
end