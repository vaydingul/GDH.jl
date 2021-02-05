# Include necessary custom functions
include("functions.jl")
# Necessary libraries
using Test
using GDH: DataHandler, add_data_read_method, add_data_load_method, add_data_preprocess_method
using GDH: NetworkData
using FunctionLib, GDH
using DelimitedFiles: readdlm

# Dummy test data paths
TEST_DATA_PATH_1 = ["test/example_data/foo/"]
TEST_DATA_PATH_2 = "test/example_data/bar/"

@info "Initialization of the objects that will be used in testing."

# DataHandler object empty initialization
dh = DataHandler()
# Addition of the necessary function to the handler
add_data_read_method(dh, FunctionHolder(read_data, (), Dict()))
add_data_load_method(dh, FunctionHolder(readdlm, (',', Float32), Dict()))
add_data_preprocess_method(dh, FunctionHolder(preprocess_data, (), Dict()))	


nd = NetworkData(dh, TEST_DATA_PATH_2)
