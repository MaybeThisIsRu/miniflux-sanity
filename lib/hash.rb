class ::Hash
	# https://stackoverflow.com/a/25990044/2464435
	def deep_merge(second)

		merger = proc { |_, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : Array === v1 && Array === v2 ? v1 | v2 : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
		merge(second.to_h, &merger)
	end
end