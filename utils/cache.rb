require "json"
class Cache
	attr_accessor :size, :last_fetched

	def initialize(path:)
		@config = {
			:path => path
		}

		@size = File.readable?(@config[:path]) ? JSON.parse(File.read(@config[:path]).to_s)["data"].count : 0

		@last_fetched = File.readable?(@config[:path]) ? JSON.parse(File.read(@config[:path]).to_s)["last_fetched"] : nil
	end

	def read_from_file
		if File.readable? @config[:path]
			JSON.parse(File.read(@config[:path]).to_s)
		else
			return {
				"size" => 0,
				"last_fetched" => nil,
				"data" => Array.new
			}
		end
	end
		end
	end

	def add_entries_to_file(data:)
		cache = self.read_from_file
		new_entries_count = 0

		# If an entry doesn't exist in the cache, we add it.
		data.each do |new_entry|
			unless cache["data"].find_index { |cache_entry| cache_entry["id"] == new_entry["id"] }
				cache["data"].push (new_entry.filter { |key| key != "content" })
				new_entries_count += 1
			end
		end

		self.size = cache["data"].count
		self.last_fetched = Date.today
		self.write_to_file data: cache

		p "#{new_entries_count} new entries were written to cache."
	end

	def write_to_file(data:)
		data["size"] = @size
		data["last_fetched"] = @last_fetched
		File.write(@config[:path], data.to_json)
	end
end