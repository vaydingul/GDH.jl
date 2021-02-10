function read_data(path)
	
	# Array initialization
	data = Array{Tuple{String, Int}, 1}([])

	# Counter initialization
	y_counter = 0;

	for (root, dirs, files) in walkdir(path)


		if !isempty(files)

			for file in files
				push!(data, (joinpath(root, file), y_counter)) # path to files
			end

			y_counter += 1
		end
	
	end
	data
end