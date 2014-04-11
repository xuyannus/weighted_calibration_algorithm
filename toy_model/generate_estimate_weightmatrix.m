function it_estimate_weightmatrix = generate_estimate_weightmatrix(yplus,yminus, thetadif ) 

    n_y=length(yplus);
    n_x=length(thetadif);
    ydiff=yplus-yminus;
    it_estimate_weightmatrix=zeros(n_x,n_y);
    
    esti_K=zeros(n_x,n_y);
    for j=1:1:n_y
        esti_K(:,j)=ydiff(j)./thetadif;
        %esti_K(:,j)=max(0.01,esti_K(:,j));
    end

    %esti_C=zeros(n_x, n_x);
    %for i=1:1:n_x
    %    esti_C(:,i)=thetadif(i)./thetadif;
    %end
    
    %W=zeros(n_x,n_y);
    %for j=1:1:n_y    
    %    re=(ydiff(j)./thetadif);
    %    b=esti_C\re;
    %    %b=regress(re, esti_C);
    %    W(:,j)=b;
    %end
    
    it_estimate_weightmatrix=esti_K;
end

