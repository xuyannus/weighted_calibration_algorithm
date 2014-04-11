clc
clear

load wm;
[p,m]=size(estimate_weightmatrix);
threshold=0.4;
par=1;  %how much we should estimate


%give threshold
for i=1:1:p
    for j=1:1:m
        if estimate_weightmatrix(i,j)<threshold
            estimate_weightmatrix(i,j)=0;
        else
            estimate_weightmatrix(i,j)=1;
        end
    end
end


re_par=1-par;
for i=1:1:p
    if i < p * re_par
        estimate_weightmatrix(i,:)=wmatrix_all(i,:);
    end
end

%i!=j  there is correlation
for i=1:1:p
    for j=1:1:m
        if ceil(i/n_x)==ceil(j/n_y)
        else
            estimate_weightmatrix(i,j)=0;
        end
    end
end

%give threshold
for i=1:1:p
    for j=1:1:m
        if estimate_weightmatrix(i,j) >0
            estimate_weightmatrix(i,j)=1;
        end
    end
end

save modified_wm;
pertagetest(wmatrix_all,estimate_weightmatrix)