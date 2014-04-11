function percentage= pertagetest(wmatrix_all,estimate_weightmatrix) 
[p,m]=size(wmatrix_all);
count1=zeros(m,1);
total=zeros(m,1);
count2=zeros(m,1);
es=zeros(m,1);

for j=1:1:m
    for i=1:1:p
        if wmatrix_all(i,j)>0 && estimate_weightmatrix(i,j)>0
            count1(j)=count1(j)+1;
        end
        if wmatrix_all(i,j)==0 && estimate_weightmatrix(i,j)==0
            count2(j)=count2(j)+1;
        end
        if wmatrix_all(i,j)>0
            total(j)=total(j)+1;
        end
        if estimate_weightmatrix(i,j)>0
            es(j)=es(j)+1;
        end
    end
end
percentage_all=mean((count1+count2) ./ p)
percentage_true=mean(count1 ./ total)
percentage_acc=mean(count1)/mean(es)
percentage=[percentage_all;percentage_true;percentage_acc];
end
