function evidence = multids( all_evidence )
%MULTIDS Summary of this function goes here
%   Detailed explanation goes here
[m,n]=size(all_evidence);
temp=zeros(1,2);
useful_evi(:,1)=all_evidence(:,1);
useful_evi(:,2)=all_evidence(:,3);

for i=1:1:m-1
    if i==1
        temp=dsevidence(useful_evi(i,:),useful_evi(i+1,:));
    else
        temp=dsevidence(temp,useful_evi(i+1,:));
    end
end

evidence=temp;
    

end

