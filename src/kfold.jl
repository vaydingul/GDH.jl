export kfold

using Random

struct kfold{T} 
    #= 

        K-FOLD cross validation seperator for the data =#

    folds::Array{Tuple{T, T}}

end

"""
    General constructor for kfold struct

    kfold
        - It seperated the given data into kfold for training

    Example:
        kf = kfold(nd ; fold = 3)

    Input:
        nd = Abstract NetworkData object
        fold = Fold count

    Output:
        result = Constructed kfold object 
"""
kfold

function kfold(nd::NetworkData{S}; fold=10)  where S <: Online
    
    folds_ = Array{Tuple{NetworkData{S}, NetworkData{S}}}([])

    # Get size of the input data
    n = length(nd.data)#[end]
    if fold > n
        throw(ErrorException("There are more fold requested than the number of samples."))
    end
    # We need to consider about sample size

    # Get permuted form of the indexes
    
    data_ = nd.shuffle ? nd.data[randperm(n)] : nd.data

    # How many elements will be in one fold?
    # We are excluding the remaining elements
    fold_size = div(n, fold)


    for k in 1:fold

        # Lower and upper bounds of the folds
        l_test = (k - 1) * fold_size + 1
        u_test = k * fold_size

        tst = [l_test:u_test...]
        trn = [1:(l_test - 1)...,(u_test + 1):n...]
        # Minibatching operation for each folding set
        push!(folds_, (NetworkData(data_[trn], nd), NetworkData(data_[tst], nd)))


    end

    # Return constructed kfold_ object
    kfold{NetworkData{S}}(folds_)

end


function kfold(nd::NetworkData{S}; fold=10) where S <: Offline
    
    folds_ = Array{Tuple{NetworkData{S}, NetworkData{S}}}([])

    # Get size of the input data
    n = size(nd.X)[end]
    # We need to consider about sample size
    if fold > n
        throw(ErrorException("There are more fold requested than the number of samples."))
    end
    # Get permuted form of the indexes
    
    X_ = nd.shuffle ? nd.X[randperm(n)] : nd.X
    y_ = nd.shuffle ? nd.y[randperm(n)] : nd.y

    # How many elements will be in one fold?
    # We are excluding the remaining elements
    fold_size = div(n, fold)


    for k in 1:fold

        # Lower and upper bounds of the folds
        l_test = (k - 1) * fold_size + 1
        u_test = k * fold_size

        tst = [l_test:u_test...]
        trn = [1:(l_test - 1)...,(u_test + 1):n...]
        # Minibatching operation for each folding set
        push!(folds_, (NetworkData(X_[:, trn], y_[:, trn], nd), NetworkData(X_[:, tst], y_[:, tst], nd)))


    end

    # Return constructed kfold_ object
    return kfold{NetworkData{S}}(folds_)

end