%it will be used in pattern 5, using D-S ingerence
function evidence = dsevidence( x, y )
%DSEVIDENCE Summary of this function goes here
%   Detailed explanation goes here
[nx,mx]=size(x);
[ny,my]=size(x);
evidence=zeros(1,mx);
temp=0;

for j=1:mx
    for k=1:my
        if(j~=k)
           temp=temp+x(j)*y(k);
        end
    end
end

for i=1:mx
    temp1=0;
    for j=1:my
        if(i==j)
            temp1=temp1+x(i)*y(j);
        end
    end
    evidence(i)=temp1/(1-temp);
end


end

