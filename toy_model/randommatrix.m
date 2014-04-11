function  weightmatrix  = randommatrix( ratio, ew_Tmp )
%RANDOMMATRIX Summary of this function goes here
%   Detailed explanation goes here
[p,m]=size(ew_Tmp);
%Generate correlation matrix
weightmatrix = rand(p, m);
th=1-ratio;
%if there is threshold
for i=1:p
    for j = 1:m
        if weightmatrix(i, j) < th
            weightmatrix(i, j) = 0;
        else
            weightmatrix(i, j) = 1;
        end
    end
end

end

