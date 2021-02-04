# Include necessary custom functions
include("functions.jl")
# Necessary libraries
using Test
using GDH: DataHandler, add_data_read_method, add_data_load_method, add_data_preprocess_method
using FunctionLib, GDH
using DelimitedFiles: readdlm

# Dummy test data paths
TEST_DATA_PATH_1 = ["test/example_data/foo/"]
TEST_DATA_PATH_2 = "test/example_data/bar/"

@info "Initialization of the objects that will be used in testing."

# DataHandler object empty initialization
dh = DataHandler()
# Addition of the necessary function to the handler
add_data_read_method(dh, FunctionHolder(read_data, (TEST_DATA_PATH_1), Dict()))
add_data_load_method(dh, FunctionHolder(readdlm, (',', Float32), Dict()))
add_data_preprocess_method(dh, FunctionHolder(preprocess_data, (), Dict()))	

# Low level function operations
X, y = [], []
data = dh.data_read_method[1]()

for datum in data

	push!(X, dh.data_load_method[1](datum[1]))
	push!(y, datum[2])

end

X_, y_ = dh.data_preprocess_method[1](X, y)


# This test is intented to verify the working accuracy
# of the low level function operation.
@testset "Low-level DataHandler Test Set" begin
	@testset "Data reading" begin

		# Type check
		@test typeof(data) <: Tuple{String, Int}
		# Value check
		@test (data[1][1] == TEST_DATA_PATH_1 + "bar/1.txt") 
		@test (data[2][1] == TEST_DATA_PATH_1 + "bar/2.txt")

		@test (data[3][1] == TEST_DATA_PATH_1 + "foo/1.txt") 
		@test (data[4][1] == TEST_DATA_PATH_1 + "foo/2.txt")

		@test data[1][2] == 0
		@test data[2][2] == 0

		@test data[3][2] == 1
		@test data[4][2] == 1
	end

	@testset "Data loading" begin
		
		@test X == [[1,2,3],[4,5,6],[7,8,9],[10,11,12]]
		@test y == [0, 0, 1, 1]

	end

	@testset "Data preprocess" begin
		
		@test X_ == X.^2 .+ 1
		@test y_ == y.^2 .+ 2

	end
end
