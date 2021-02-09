export NetworkData
import Base: iterate, show


abstract type AbstractNetworkData end
mutable struct NetworkData{T} <: AbstractNetworkData

    data_handler::AbstractDataHandler
    
    data::Array{Tuple{String,Int8}} # Paths of the individual data point and labels

    X # Temporary data fields to be stored in CPU
    y # Temporary data fields to be stored in CPU

    shuffle::Bool
    batchsize::Int # Batchsize during training
    length
    partial
    imax

    atype
    xsize
    ysize
    xtype
    ytype

end

function NetworkData(data_handler::DataHandler{T}, main_path; shuffle::Bool=false, batchsize::Int=1, partial=false,
                    atype=Array{Float32}, xsize=nothing, ysize=nothing, xtype=nothing, ytype=nothing) where T <: AbstractStatus
            
    data = data_handler.data_read_method(main_path)
    
    if T === Online

        # read_count_ = read_count === nothing ? floor(Int, length(data) * read_rate) : read_count # Number of data points to read each time
        
        # refresh_rate = floor(Int, read_count / batchsize)

        n = length(data)
        X2 = y2 = nothing

    else

        X, y = [], []

        for datum in data

            push!(X, data_handler.data_load_method(datum[1]))
	    push!(y, datum[2])

        end

        for fh in data_handler.data_preprocess_method

            X, y = fh(X, y) 

        end

        xsize = xsize === nothing && size(X)
        ysize = ysize === nothing && size(y)
        xtype = xtype === nothing && (eltype(X) <: AbstractFloat ? atype : (typeof(X).name.wrapper){eltype(x)})
        ytype = ytype === nothing && (eltype(y) <: AbstractFloat ? atype : (typeof(y).name.wrapper){eltype(y)})


        n = size(X)[end]
        X2 = reshape(X, :, n)
        y2 = reshape(y, :, n)

        if n != size(y)[end]
             throw(DimensionMismatch())
        end


    end 

    
    imax = partial ? n : n - batchsize + 1
    
    NetworkData{T}(data_handler, data, X2, y2, shuffle, batchsize, n, partial, imax, atype, xsize, ysize, xtype, ytype)

end


function NetworkData(data, nd::NetworkData{T}) where T <: AbstractStatus

    # read_count = floor(Int, length(data) * nd.read_rate) # Number of data points to read each time

    return NetworkData{T}(nd.data_handler, data, nd.X, nd.y, nd.shuffle, nd.batchsize, nd.length, nd.partial, nd.imax, nd.atype, nd.xsize, nd.ysize, nd.xtype, nd.ytype)

end


function NetworkData(X, y, nd::NetworkData{T}) where T <: AbstractStatus

    # read_count = floor(Int, length(data) * nd.read_rate) # Number of data points to read each time

    return NetworkData{T}(nd.data_handler, nd.data, X, y, nd.shuffle, nd.batchsize, nd.length, nd.partial, nd.imax, nd.atype, nd.xsize, nd.ysize, nd.xtype, nd.ytype)

end


function iterate(nd::NetworkData{T}, i=0) where T <: Offline

    if i >= nd.imax
        return nothing
    end
    
    nexti = min(i + nd.batchsize, nd.length)

    ids = i + 1:nexti

    xbatch = try 
        
        convert(nd.xtype, reshape(nd.X[:, ids], nd.xsize[1:end - 1]..., length(ids)))

    catch
    
        throw(DimensionMismatch("X tensor not compatible with size=$(nd.xsize) and type=$(nd.xtype)"))

    end

    
    ybatch = try 

        convert(nd.ytype, reshape(nd.y[:, ids], nd.ysize[1:end - 1]..., length(ids)))

    catch

        throw(DimensionMismatch("Y tensor not compatible with size=$(nd.ysize) and type=$(nd.ytype)"))
        
    end

    return ((xbatch, ybatch), nexti)
    

end

# TODO: Whole iterate in one function ?
    
function iterate(nd::NetworkData{T}, i=0) where T <: Online

    if i >= nd.imax
        return nothing
    end
    
    nexti = min(i + nd.batchsize, nd.length)

    ids = i + 1:nexti

        X, y = [], []

    for ix in ids

        push!(X, nd.data_handler.data_load_method(nd.data[ix][1]))
        push!(y, nd.data[ix][2])

    end

    for fh in nd.data_handler.data_preprocess_method

        X, y = fh(X, y) 

    end

    # TODO: Make more robust, and in an error handling
    xbatch = nd.xsize !== nothing ? reshape(X, nd.xsize[1:end - 1]..., length(ids)) : X
    ybatch = nd.ysize !== nothing ? reshape(y, nd.ysize[1:end - 1]..., length(ids)) : y
    xbatch = nd.xtype !== nothing ? convert(nd.xtype, xbatch) : xbatch
    ybatch = nd.ytype !== nothing ? convert(nd.ytype, ybatch) : ybatch



#= 
    xbatch = try 
        
        convert(nd.xtype, reshape(X, nd.xsize[1:end-1]..., length(ids)))

    catch

        throw(DimensionMismatch("X tensor not compatible with size=$(nd.xsize) and type=$(nd.xtype)"))

    end

    
    ybatch = try 

        convert(nd.ytype, reshape(y, nd.ysize[1:end-1]..., length(ids)))

    catch

        throw(DimensionMismatch("Y tensor not compatible with size=$(nd.ysize) and type=$(nd.ytype)"))
        
    end =#
    
    return ((xbatch, ybatch), nexti)
    

end


function length(nd::NetworkData{T}) where T <: AbstractStatus
     
    len = nd.length / nd.batchsize
    nd.partial ? ceil(Int, len) : floor(Int, len)

end


function show(io::IO, nd::NetworkData{T}) where T <: AbstractStatus

println("\n$T Network Data:\n")
println("DataHandler: ", nd.data_handler)
println("Data: ", nd.data)
println("Shuffle Option: ", nd.shuffle)
println("Batchsize: ", nd.batchsize)
println("Array Type: ", nd.atype)
println("X Tensor: ", nd.X)
println("y Tensor: ", nd.y)
println("Length: ", nd.length)
println("Partial Option: ", nd.partial)
println("imax: ", nd.imax)
println("X Tensor Size: ", nd.xsize)
println("y Tensor Size: ", nd.ysize)
println("X Tensor Type: ", nd.xtype)
println("y Tensor Type: ", nd.ytype,"\n")

end

function show(io::IO, ::MIME"text/plain", nd::NetworkData{T}) where T <: AbstractStatus
    
    show(io, nd)

end


















############### DEPRECATED CODE ####################################################
#= 
function length(nd::NetworkData{T}) where T <: AbstractStatus
     
    len = nd.length / nd.batchsize
    nd.partial ? ceil(Int,len) : floor(Int,len)


    #=
    part = ceil(Int, length(nd.data) / nd.read_count)
    
    if nd.X_ !== nothing
        each_part = ceil(Int, length(nd.y_) / nd.batchsize)
        return part * each_part
    else
        return part
    end
    =#
    #=
    l = 0

    part_cnt, rem_cnt = divrem(length(nd.data), nd.read_count)
    
    l = ceil(Int, nd.read_count / nd.batchsize) * part_cnt
    
    l += ceil(Int, rem_cnt / nd.batchsize)

    return l
    =#


    #= 
    n = length(nd.data) / nd.batchsize
    ceil(Int,n) =#
end =#


#= 
function iterate(nd::NetworkData, state=(0, 0, true))

    s1, s2, s3 = state


    if nd.y_ !== nothing

        if (length(nd.data) - s1 <= 0) && (length(nd.y_) - s2 <= 0)

            return nothing
    
        end

        s2 = s2 % length(nd.y_)
        ps = length(nd.y_)

        # When we porocess an inout , it does not result in one-to-one relationship.
        # One inout may output as multiple modified version.
        # This state will check this situation.
        next_s2 = s2 + min(nd.batchsize, ps - s2)

        # This state is responsible for the data samples, which is one-to-one inherently.
        next_s1 = s3 ? min(s1 + nd.read_count, length(nd.data)) : s1 + 0
        #next_s1 = next_s2 == ps && s3 ? min(s1 + nd.read_count, length(nd.data)) : s1 + 0

        next_s3 = next_s2 == ps ? true : false

    else
        next_s2 = s2 + nd.batchsize

        # This state is responsible for the data samples, which is one-to-one inherently.
        next_s1 = s1 +  nd.read_count
    
        next_s3 = false

    end
    next_state = (next_s1, next_s2, next_s3)
    # nexti = i + min(nd.batchsize, length(nd.data) - i, nd.read_count - (i % nd.read_count))

    if s3

        y = vcat([nd.data[k][2] for k in s1 + 1:next_s1]...)
        println("Data reading...")
        #=
        if nd.type == "image"

            X = [load(nd.data[k][1]) for k in s1 + 1:next_s1]
            p1 = FlipX()
            p2 = FlipY()
            p3 = FlipX() |> FlipY()
            X, y = augment_image(X, y, p1, p2, p3)
            # Apply preprocessing on the images
            nd.X_, nd.y_ = process_image(X, y)
    
        else
    
            X = [vec(readdlm(nd.data[k][1], '\n', Float32)) for k in s1 + 1:next_s1]
            nd.X_, nd.y_ = process_accel_signal(X, y)

        end
        =#
        
        for load_ops in T.data_load_method

            nd.X_, nd.y_ = load_ops(nd.X_, nd.y_)

        end

        for preprocess_ops in T.data_preprocess_method

            nd.X_, nd.y_ = preprocess_ops(nd.X_, nd.y_)

        end
    end

    # ids = [i + 1:nexti]

    Xbatch = convert(nd.atype, nd.X_[:,:,:,s2 + 1:next_s2])
    ybatch = nd.y_[s2 + 1:next_s2]

    #println.([state, next_state, length(nd.y_)])


    return ((Xbatch, ybatch), next_state)
    
end =#


#= 

function iterate(nd::NetworkData, i=0)

    if length(nd.data) - i <= 0

        return nothing

    end

    nexti = min(i + nd.batchsize, length(nd.data))
    #nexti = i + nd.batchsize

    y = vcat([nd.data[k][2] for k in i + 1:nexti]...)

    if nd.type == "image"

        X = [load(nd.data[k][1]) for k in i + 1:nexti]
        p1 = FlipX()
        p2 = FlipY()
        p3 = FlipX() |> FlipY()
        X, y = augment_image(X, y, p1, p2, p3)
        # Apply preprocessing on the images
        X, y = process_image(X, y)

    else

        X = [vec(readdlm(nd.data[k][1], '\n', Float32)) for k in i + 1:nexti]
        X, y = process_accel_signal(X, y)
    end

    #ids = [i + 1:nexti]

    X = convert(nd.atype, X)
    
    return ((X, y), nexti)
    
end =#