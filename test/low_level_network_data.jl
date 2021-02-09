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

# DataHandler object empty initialization
dh = DataHandler(false, FunctionHolder(read_data, (), Dict()),
						FunctionHolder(readdlm, (',', Float32), Dict()))
# Addition of the necessary function to the handler
add_data_preprocess_method(dh, FunctionHolder(preprocess_data, (), Dict()))	


nd1 = NetworkData(dh, TEST_DATA_PATH_1)

@testset "Offline Data Handler Data Check" begin
	
	X = Any[Float32[1.0 2.0 3.0],Float32[4.0 5.0 6.0],Float32[7.0 8.0 9.0],Float32[10.0 11.0 12.0]]
	y = [0 0 1 1]
	
	@test nd1.X == hcat(X'...).^2 .+ 1
	@test nd1.y == y.^2 .+ 2

end

@testset "Offline Data Handler Iterator Check" begin

	nd1_iterated = collect(nd1)

	@test vec(nd1_iterated[1][1]) == nd1.X[:, 1]
	@test vec(nd1_iterated[2][1]) == nd1.X[:, 2]
	@test vec(nd1_iterated[3][1]) == nd1.X[:, 3]
	@test vec(nd1_iterated[4][1]) == nd1.X[:, 4]
	
	@test nd1_iterated[1][2][1] == nd1.y[1]
	@test nd1_iterated[2][2][1] == nd1.y[2]
	@test nd1_iterated[3][2][1] == nd1.y[3]
	@test nd1_iterated[4][2][1] == nd1.y[4]


end

# DataHandler object empty initialization
dh = DataHandler(true, FunctionHolder(read_data, (), Dict()),
						FunctionHolder(readdlm, (',', Float32), Dict()))
# Addition of the necessary function to the handler
add_data_preprocess_method(dh, FunctionHolder(preprocess_data, (), Dict()))	

nd2 = NetworkData(dh, TEST_DATA_PATH_2)


@testset "Online Data Handler Iterator Check" begin

	nd2_iterated = collect(nd2)

	@test vec(nd2_iterated[1][1]) == nd1.X[:, 1]
	@test vec(nd2_iterated[2][1]) == nd1.X[:, 2]
	@test vec(nd2_iterated[3][1]) == nd1.X[:, 3]
	@test vec(nd2_iterated[4][1]) == nd1.X[:, 4]

	@test nd2_iterated[1][2][1] == nd1.y[1]
	@test nd2_iterated[2][2][1] == nd1.y[2]
	@test nd2_iterated[3][2][1] == nd1.y[3]
	@test nd2_iterated[4][2][1] == nd1.y[4]

end
