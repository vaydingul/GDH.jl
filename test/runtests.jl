using Test
# Include necessary custom functions
include("functions.jl")
# Necessary libraries
using Test
using GDH: DataHandler, add_data_read_method, add_data_load_method, add_data_preprocess_method
using GDH: NetworkData
using FunctionLib: FunctionHolder
using FunctionLib, GDH
using DelimitedFiles: readdlm



@testset "Main GDH Test" begin
	
	include("low_level_data_handler.jl");
	include("low_level_network_data.jl");
	include("kfold_test.jl")
	
end