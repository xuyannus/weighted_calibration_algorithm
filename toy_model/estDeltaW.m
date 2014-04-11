function Delta_W = estDeltaW(Error,Grad,dimension)


[horizon,m] = size(Error);
[horizon,p] = size(Grad);
if dimension < horizon
    horizon = dimension;
end

ErrorTmp = Error(1:horizon,:);
GradTmp = Grad(1:horizon,:);
Delta_W = zeros(p,m);

%Error_Norm = ones(horizon,1);
for i = 1:m % every column of the Error matrix
    ErrorVector = ErrorTmp(:,i);
    for ii = 1:horizon % every row of Grad matrix
        GradTmp(ii,:) = GradTmp(ii,:) ./ ErrorVector(ii);
    end
    
    rangeGrad = range(GradTmp); % range of each column
    [rangeSort,rangeIndex] = sort(rangeGrad); % sort
    GradTmp = Grad(1:horizon,:); % re-initialize
    
    inv_Grad = zeros(horizon,horizon);
    inv_Grad = GradTmp(:,rangeIndex(1:horizon));
    
    while det(inv_Grad) < 1
        horizon = horizon - 1;
        inv_Grad = zeros(horizon,horizon);
        GradTmp = Grad(1:horizon,:);
        inv_Grad = GradTmp(:,rangeIndex(1:horizon));
    end
    
    if horizon > 0
        ErrorVector = ErrorTmp(1:horizon,i);
        WVector = inv(inv_Grad) * ErrorVector;
    end
    
    for ii = 1:horizon
        Delta_W(rangeIndex(ii),i)=WVector(ii);
    end
    
end

end

