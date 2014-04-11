%This code will combine the perfect od_matrix with the estimate Wh, so if we know some good knowledge of the network, we can replace the estimate one to get the good answer.
%By MaWei,19.08.2013
clc
clear all

%read the number
%this part will load the number of each parameter
cd ..
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
no_sensors=58;
no_intervals_real = 9  %no_intervals_real = end_interval - start_interval - warm_up + 1

%replace one by one
cd replace
load wh.dat;
p_all=size(wmatrix,1);

%For od
if(exist('modified_od_perfect.dat','file'))
  load modified_od_perfect.dat;
  flag=0;
  k=1;
  while(flag==0)
    if wmatrix(k,1) > no_ODs * no_intervals_real
      flag=1;
    end
    k=k+1;
  end
  new_wmatrix=[modified_od_perfect;wmatrix(k:p_all,:)];
end

%For cap 
if(exist('cap_perfect.dat','file'))

end

save new_wh.dat new_wmatrix -ascii;

disp('Finish!')
