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
dh = DataHandler(false, FunctionHolder(read_data, (TEST_DATA_PATH_1), Dict()),
						FunctionHolder(readdlm, (',', Float32), Dict()))
#dh = DataHandler(false)
# Addition of the necessary function to the handler
#add_data_read_method(dh, FunctionHolder(read_data, (TEST_DATA_PATH_1), Dict()))
#add_data_load_method(dh, FunctionHolder(readdlm, (',', Float32), Dict()))
add_data_preprocess_method(dh, FunctionHolder(preprocess_data, (), Dict()))	

# Low level function operations
X, y = [], []
data = dh.data_read_method()

for datum in data

	push!(X, dh.data_load_method(datum[1]))
	push!(y, datum[2])

end

X_, y_ = dh.data_preprocess_method[1](X, y)


# This test is intented to verify the working accuracy
# of the low level function operation.
@testset "Low-level DataHandler Test Set" begin
	@testset "Data reading" begin

		# Type check
		@test typeof(data) <: Array{Tuple{String, Int}, 1}
		@test eltype(data) <: Tuple{String, Int}
		# Value check
		@test (data[1][1] == TEST_DATA_PATH_1[1] * "bar/1.txt") 
		@test (data[2][1] == TEST_DATA_PATH_1[1] * "bar/2.txt")

		@test (data[3][1] == TEST_DATA_PATH_1[1] * "foo/1.txt") 
		@test (data[4][1] == TEST_DATA_PATH_1[1] * "foo/2.txt")

		@test data[1][2] == 0
		@test data[2][2] == 0

		@test data[3][2] == 1
		@test data[4][2] == 1
	end

	@testset "Data loading" begin
		
		@test X == Any[Float32[1.0 2.0 3.0],Float32[4.0 5.0 6.0],Float32[7.0 8.0 9.0],Float32[10.0 11.0 12.0]]
		@test y == [0, 0, 1, 1]

	end

	@testset "Data preprocess" begin
		
		@test X_ == hcat(X'...).^2 .+ 1
		@test y_ == y.^2 .+ 2

	end
end
