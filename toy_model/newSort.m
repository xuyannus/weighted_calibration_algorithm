function [result,index] = newSort(vector,num)

len=length(vector);
vectorTmp=vector;
index=ones(num, 1);
result=zeros(num, 1);
maxe=max(vectorTmp)+1;
for i=1:1:num
    [result(i),index(i)]=min(vectorTmp);
    vectorTmp(index(i))=maxe; % set max value  as 0
end

end

