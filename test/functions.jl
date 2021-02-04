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


function preprocess_data(X, y; ops1 = 1, ops2 = 2)

	return X .^ 2 .+ ops1, y .^ 2 .+ ops2 

end