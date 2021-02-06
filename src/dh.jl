export iterate, length, NetworkData, DataHandler

using FunctionLib
import Base: length, iterate, vcat

abstract type GenericDataHandler end

mutable struct DataHandler <: GenericDataHandler
    # Tuple of method and its arguments
    # The defined method should walk the directory of the data
    # and fetch the directories of the individual datum and label;
    # finally, should return an array of tuples consisting of the directories
    # and the labels.
    data_read_method::Array{FunctionHolder} 
    # Array of tuples consisting of functions and its arguments
    data_load_method::Array{FunctionHolder}
    data_preprocess_method::Array{FunctionHolder}
    # Loading method
    is_online::Bool


    # Uninitialized construction
    DataHandler() = new(Array{FunctionHolder}[], Array{FunctionHolder}[], Array{FunctionHolder}[], true)
end


function add_data_read_method(dh::DataHandler, method::FunctionHolder)

    push!(dh.data_read_method, method)

end

function add_data_load_method(dh::DataHandler, method::FunctionHolder)

    push!(dh.data_load_method, method)

end

function add_data_preprocess_method(dh::DataHandler, method::FunctionHolder)

    push!(dh.data_preprocess_method, method)

end
