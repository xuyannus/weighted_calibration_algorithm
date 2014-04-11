%This code use sort to evaluate the importance of each parameter
%and it can be written in different forms, for examples, range std etc.
%and we may use bootstrap(more time) to make result more accurate.
%By Ma Wei and Hao min
%10,08,2013
function it_estimate_weightmatrix = horizon_estimate( T_DIFF, Y_DIFF, interval )

[horizon,p] = size(T_DIFF);
[horizon,m] = size(Y_DIFF);
it_estimate_weightmatrix=zeros(p,m);
n_x=p/interval;
n_y=m/interval;

    %tic
for k=1:m
    TmpF=Y_DIFF(:,k);
    D_Matrix=zeros(horizon, p);
    for i=1:horizon
        D_Matrix(i,:)=TmpF(i) ./ T_DIFF(i,:);
    end
    meanDMat=mean(D_Matrix);
    stdDMat=std(D_Matrix);

    for i=1:1:horizon
        D_Matrix(i,:)=(D_Matrix(i,:)-meanDMat)./stdDMat;
    end

    [SortVAR, Index]= sort(var(D_Matrix));

    
    for t=1:1:horizon
        it_estimate_weightmatrix(Index(t),k) = 1;
    end

end

end
