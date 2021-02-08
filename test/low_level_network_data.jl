# Include necessary custom functions
include("functions.jl")
# Necessary libraries
using Test
using GDH: DataHandler, add_data_read_method, add_data_load_method, add_data_preprocess_method
using GDH: NetworkData
using FunctionLib: FunctionHolder
using FunctionLib, GDH
using DelimitedFiles: readdlm

# Dummy test data paths
TEST_DATA_PATH_1 = "test/example_data/foo/"
TEST_DATA_PATH_2 = "test/example_data/bar/"

@info "Initialization of the objects that will be used in testing."

# DataHandler object empty initialization
dh = DataHandler(false, FunctionHolder(read_data, (), Dict()),
						FunctionHolder(readdlm, (',', Float32), Dict()))
# Addition of the necessary function to the handler
add_data_preprocess_method(dh, FunctionHolder(preprocess_data, (), Dict()))	


nd = NetworkData(dh, TEST_DATA_PATH_1)

@testset "Offline Data Handler Data Check" begin
	
	X = Any[Float32[1.0 2.0 3.0],Float32[4.0 5.0 6.0],Float32[7.0 8.0 9.0],Float32[10.0 11.0 12.0]]
	y = [0 0 1 1]
	
	@test nd.X == hcat(X'...).^2 .+ 1
	@test nd.y == y.^2 .+ 2

end

@testset "Offline Data Handler Iterator Check" begin

@show	nd_iterated = collect(nd)

end
