export DataHandler

using FunctionLib: FunctionHolder
import Base: length, iterate, vcat, show

abstract type AbstractDataHandler end
abstract type AbstractStatus end

struct Online <: AbstractStatus; end
struct Offline <: AbstractStatus; end


mutable struct DataHandler{T} <: AbstractDataHandler
    # Tuple of method and its arguments
    # The defined method should walk the directory of the data
    # and fetch the directories of the individual datum and label;
    # finally, should return an array of tuples consisting of the directories
    # and the labels.
    data_read_method::FunctionHolder 
    # Array of tuples consisting of functions and its arguments
    data_load_method::FunctionHolder
    data_preprocess_method::Array{FunctionHolder}
    
    #DataHandler() = new()

    
    # Uninitialized construction
    #DataHandler() = new(Array{FunctionHolder}[], Array{FunctionHolder}[], Array{FunctionHolder}[])
end

function DataHandler(is_online::Bool,   data_read_method::FunctionHolder,
                                        data_load_method::FunctionHolder;
                                        data_preprocess_method::Array{FunctionHolder} = Array{FunctionHolder}([]))

is_online ? DataHandler{Online}(data_read_method, data_load_method, data_preprocess_method) : DataHandler{Offline}(data_read_method, data_load_method, data_preprocess_method)

end

function add_data_read_method(dh::AbstractDataHandler, method::FunctionHolder)

    dh.data_read_method = method

end

function add_data_load_method(dh::AbstractDataHandler, method::FunctionHolder)

    dh.data_load_method = method

end

function add_data_preprocess_method(dh::AbstractDataHandler, method::FunctionHolder)

    push!(dh.data_preprocess_method, method)

end



function show(io::IO, dh::DataHandler{T}) where T<:AbstractStatus

    println("\n$T Data Handler:\n")
    println("Data Reading Method => ", dh.data_read_method)
    println("Data Loading Method => ", dh.data_load_method)
    println("Data Preprocessing Method => ", dh.data_preprocess_method, "\n")

end
    
function show(io::IO, ::MIME"text/plain", dh::DataHandler{T}) where T <: AbstractStatus
        
        show(io, dh)
    
end