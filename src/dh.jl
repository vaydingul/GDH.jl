export iterate, length, NetworkData, DataHandler

using FunctionLib
import Base: length, iterate, vcat

abstract type AbstractDataHandler end
abstract type AbstractStatus end

struct Online; end
struct Offline; end


mutable struct DataHandler{T} <: AbstractDataHandler
    # Tuple of method and its arguments
    # The defined method should walk the directory of the data
    # and fetch the directories of the individual datum and label;
    # finally, should return an array of tuples consisting of the directories
    # and the labels.
    data_read_method::Array{FunctionHolder} 
    # Array of tuples consisting of functions and its arguments
    data_load_method::Array{FunctionHolder}
    data_preprocess_method::Array{FunctionHolder}



    # Uninitialized construction
    DataHandler() = new(Array{FunctionHolder}[], Array{FunctionHolder}[], Array{FunctionHolder}[])
end

function DataHandler(is_online::Bool; data_read_method::Array{FunctionHolder} = Array{FunctionHolder}[],
    data_load_method::Array{FunctionHolder} = Array{FunctionHolder}[],
    data_preprocess_method::Array{FunctionHolder = Array{FunctionHolder}[]}
)

is_online ? DataHandler{Online}(data_read_method, data_load_method, data_preprocess_method) : DataHandler{Offline}(data_read_method, data_load_method, data_preprocess_method)

end

function add_data_read_method(dh::AbstractDataHandler, method::FunctionHolder)

    push!(dh.data_read_method, method)

end

function add_data_load_method(dh::AbstractDataHandler, method::FunctionHolder)

    push!(dh.data_load_method, method)

end

function add_data_preprocess_method(dh::AbstractDataHandler, method::FunctionHolder)

    push!(dh.data_preprocess_method, method)

end