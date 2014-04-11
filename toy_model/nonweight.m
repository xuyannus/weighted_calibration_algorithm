function NonWeightMatrix = nonweight( wmatrix_all, secondorder_all, theta ,ratio)

[p, m]=size(wmatrix_all);
weight=zeros(p, m);
parfor i=1:1:p
    weight(i,:)= 2 * theta(i) .* secondorder_all(i,:);
end

NonWeightMatrix = weight + wmatrix_all;
    
for i=1:1:p
    if i < ratio*p
        
    else
        NonWeightMatrix(i,:)=ones(1,m);
    end
end
    

end

