%This code will re-set the weight matrix
function after_cut_weight = cut_after_gen( p,m, step )
%CUT_AFTER_GEN Summary of this function goes here
%   Detailed explanation goes here
global weight_percentage;

after_cut_weight=zeros(p,m);
rand_com= rand(p,m);

for i=1:p
    for j=1:m
        if rand_com(i,j)>weight_percentage(i,j)
        else 
            after_cut_weight(i,j)=step;
        end
    end
end

end

