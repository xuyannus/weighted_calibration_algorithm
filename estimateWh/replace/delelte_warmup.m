%This code will delete the warm up and useless interval after the perfect matrix is made.
%By MaWei,19.08.2013

cd ..
estimate_configure;

cd replace
load od_perfect.dat;

start_int
end_int
warm_up

temp=[];

for i=1:size(od_perfect,1)
  if od_perfect(i,2) > (start_int+warm_up) * no_sensors &&  od_perfect(i,2) <= end_int * no_sensors
    od_perfect(i,2)=od_perfect(i,2) - ((start_int+warm_up) * no_sensors);
    temp=[temp;od_perfect(i,:)];
  end
end

save modified_od_perfect.dat temp -ascii;

disp('Finish!')
