export kfold

using Random

struct kfold{T} 
    #= 

        K-FOLD cross validation seperator for the data =#

    folds::Array{Tuple{T, T}}

end

"""
    General constructor for kfold_ struct

    kfold
        - It seperated the given data into kfold_ for training

    Example:
        kf = kfold(X_train, y_train; fold = 3, atype = a_type(Float32))

    Input:
        X = Input data of the model
        y = Desired output data of the model
        fold = Fold Construct
        minibatch_size = Minibatch size that will be included in each fold
        atype = Array type that will be passes
        shuffle = Shuffling option

    Output:
        result = Loss and misclassification errors of train and test dataset 
"""
kfold

function kfold(nd::D{S}; fold=10) where {D <: AbstractNetworkData, S <: Online}
    
    folds_ = Array{Tuple{D, D}}([])

    # Get size of the input data
    n = length(nd.data)#[end]
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
        push!(folds_, (D(data_[trn], nd), D(data_[tst], nd)))


    end

    # Return constructed kfold_ object
    kfold{D}(folds_)

end


function kfold(nd::D{S}; fold=10) where {D <: AbstractNetworkData, S <: Offline}
    
    folds_ = Array{Tuple{D, D}}([])

    # Get size of the input data
    n = size(nd.X)[end]
    # We need to consider about sample size

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
        push!(folds_, (D(X_[trn], y_[trn], nd), D(X_[tst], y_[tst], nd)))


    end

    # Return constructed kfold_ object
    return kfold{D}(folds_)

end