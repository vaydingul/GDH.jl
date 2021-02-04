using Test
using GDH: DataHandler
using FunctionLib, GDH
using DelimitedFiles: readdlm
TEST_DATA_PATH_1 = "example_data/foo"
TEST_DATA_PATH_2 = "example_data/bar"

@info "Tests are starting"
a = 1
dh = DataHandler()

@testset "Basic DataHandler Test Set" begin

	@show push!(dh.data_load_method ,FunctionHolder(readdlm, (), Dict()))
	@show dh
	#@test dh.data_read_method === undef

end
