%This code will simplify the estimate_weightmatrix further, using the prior information of interval, often the interval 1 parameters will not influence the interval 3s
%By Ma Wei,17,08,2013
function eliminate_weightmatrix = interval_Effect(estimate_weightmatrix, interval_effect, no_sensors)

%read the number
%this part will load the number of each parameter
cd initial
load OD_vector.dat;
load cap_vector.dat;
load spddsy_vector.dat;
load rt_choice.dat;
cd ..

no_ODs = OD_vector(1);
no_intervals = OD_vector(2);
no_segments = cap_vector(1);
no_other_params = length(rt_choice);

p = no_ODs * no_intervals + no_segments + 6 * no_segments + no_other_params;
m = no_intervals * no_sensors;

eliminate_weightmatrix = estimate_weightmatrix;

%Let's do the elimination
%For OD
if interval_effect(1) != -1
  for i = 1:no_ODs * no_intervals
    cur_interval=mod(i,no_ODs)+1;
    for j = 1:m
      %previous interval will not influence the future
      if (mod(j,no_sensors)+1) < cur_interval
        eliminate_weightmatrix(i,j)=0;
      end
      if (mod(j,no_sensors)+1) > cur_interval + interval_effect(1)
        eliminate_weightmatrix(i,j)=0;
      end
    end
  end
end

%For cap
%cap always influence all the intervals
if interval_effect(2) != -1

end

%For spddsy
%spddsy always influence all the intervals
if interval_effect(3) != -1

end     

%For rt
%rt always influence all the intervals
if interval_effect(4) != -1

end


