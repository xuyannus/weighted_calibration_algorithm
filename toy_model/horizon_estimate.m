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
        %D_Matrix(i,:)=T_DIFF(i,:)./TmpF(i);
        D_Matrix(i,:)=TmpF(i) ./ T_DIFF(i,:);
    end
    %t=toc;
    %disp('D_Matrix')
    %disp(t);
    meanDMat=mean(D_Matrix);
    stdDMat=std(D_Matrix);
   %normalize to mean=0,std=1
    for i=1:1:horizon
        D_Matrix(i,:)=(D_Matrix(i,:)-meanDMat)./stdDMat;
    end
    %p_DMat=ones(1,p);
    %for i=1:1:horizon
    %    p_DMat(i,:)=normpdf(D_Matrix(i,:));
    %end
    %p_DMat_mean=mean(p_DMat);
    
    %VAR_D=range(D_Matrix);
    %VAR_D=std(D_Matrix);
    %VAR_D=mean(bootstrp(100, @std, D_Matrix));
    [SortVAR, Index]= sort(var(D_Matrix));
    %[SortVAR, Index]= sort(VAR_D);
    %indexs=[];
    %indexs=[indexs;Index];
    %tic
    %DIFF_Tmp = T_DIFF; % initialize
    
    %inv_DIFF = zeros(horizon,horizon);
    %inv_DIFF = DIFF_Tmp(:,Index(1:horizon));
    %t=toc;
    %disp('DIFF')
    %disp(t);
    %tic
    %if rank(inv_DIFF)~=horizon
    %    inv_DIFF=(1+rand*1e-3).*inv_DIFF;
    %end
    %Tmp_M=Y_DIFF(:, k);
    %Tmp_wm(:,k) = inv_DIFF \ Tmp_M;
    %t=toc;
    %disp('inv')
    %disp(t);
    %tic
    
    %only the same interval
    %NewIndex=zeros(horizon,1);
    %interval_tmp=ceil(k/n_y);
    %t=1;
    %w=1;
    %while t<=horizon
    %    if Index(w)>=(interval_tmp-1)*n_x&&Index(w)<interval_tmp* n_x
    %        NewIndex(t)=Index(w);
    %        w=w+1;
    %        t=t+1;
    %    else
    %        w=w+1;
    %    end
    %end
    
    for t=1:1:horizon
        %it_estimate_weightmatrix(Index(t),k) = Tmp_wm(t,k);
        %it_estimate_weightmatrix(NewIndex(t),k) = 1;
        it_estimate_weightmatrix(Index(t),k) = 1;
    end
    %t=toc;
    %disp('give')
    %disp(t);
    %str=['save ./Results/Indexs' num2str(k) '.dat indexs -ascii;'];
    %eval(str);
end

end
