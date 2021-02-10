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

@testset "K-fold Cross Validation Error Handling Test" begin
	fold_count = 2
	kf = kfold(nd1; fold = fold_count)
	@test length(kf.folds) == fold_count

	fold_count = 5
	@test_throws ErrorException kf = kfold(nd1; fold = fold_count)
	#@test length(kf.folds) == fold_count

end


fold_count = 2
kf = kfold(nd1; fold = fold_count)
dtrn1, dtst1 = kf.folds[1]
dtrn2, dtst2 = kf.folds[2]

@testset "K-fold Cross Validation Folding Test" begin
	
	


	dtrn1_iterated = collect(dtrn1)
	dtst1_iterated = collect(dtst1)
	dtrn2_iterated = collect(dtrn2)
	dtst2_iterated = collect(dtst2)
	
	@test vec(dtrn2_iterated[1][1]) == nd1.X[:, 1]
	@test vec(dtrn2_iterated[2][1]) == nd1.X[:, 2]
	@test vec(dtst2_iterated[1][1]) == nd1.X[:, 3]
	@test vec(dtst2_iterated[2][1]) == nd1.X[:, 4]

	@test dtrn2_iterated[1][2][1] == nd1.y[1]
	@test dtrn2_iterated[2][2][1] == nd1.y[2]
	@test dtst2_iterated[1][2][1] == nd1.y[3]
	@test dtst2_iterated[2][2][1] == nd1.y[4]


	@test vec(dtrn1_iterated[1][1]) == nd1.X[:, 3]
	@test vec(dtrn1_iterated[2][1]) == nd1.X[:, 4]
	@test vec(dtst1_iterated[1][1]) == nd1.X[:, 1]
	@test vec(dtst1_iterated[2][1]) == nd1.X[:, 2]

	@test dtrn1_iterated[1][2][1] == nd1.y[3]
	@test dtrn1_iterated[2][2][1] == nd1.y[4]
	@test dtst1_iterated[1][2][1] == nd1.y[1]
	@test dtst1_iterated[2][2][1] == nd1.y[2]
end