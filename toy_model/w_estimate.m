clc
clear

load generater;

global counter_glob;
counter_glob = 0;
    


%load x_all;
x = x_all;
paramsPerDay = length(x);

%load y_all;
y = y_all;
sensor_counts = y;
no_sen = length(y);

%load wmatrix_all;
wmatrix = wmatrix_all;

%Algorithm parameters

%how fast the grad will converge 
average_number=500;
%first assume theta is real
theta=x_true .* (1+ 0.2* rand(paramsPerDay, 1));
%range of perturbation
ck=2;

%initial
esti_wm=zeros(paramsPerDay, no_sen);
esti_wm_good=zeros(paramsPerDay, no_sen);

for i=1:1:average_number
    if mod(i,100) == 0
          i
     end
    %bernoulli distribution
    delta = 2 * round(rand(paramsPerDay,1))-1;
    
    lo = zeros(paramsPerDay,1);
    lo = lo + 0.001;
   
    thetaplus = theta + ck.*delta;
    thetaminus = theta - ck.*delta;
   
    thetaplus = max(lo, thetaplus);
    thetaminus = max(lo, thetaminus);
    
    yplus=FUNC(thetaplus, sensor_counts, false, wmatrix,secondorder_all);
    yminus=FUNC(thetaminus, sensor_counts, false, wmatrix,secondorder_all);
    
    ydiff=yplus-yminus;
    thetadiff = thetaplus - thetaminus;
    
    for j=1:1:no_sen
        esti_wm(:,j)=ydiff(j)./thetadiff;
    end

    esti_wm_good=esti_wm_good.*(i/(i+1))+esti_wm.*(1/(1+i));
end

%normlize
estimate_weightmatrix=zeros(paramsPerDay, no_sen);
for i=1:1:paramsPerDay
    esti_wm_good(i,:)=abs(esti_wm_good(i,:));
    maxe=max(esti_wm_good(i,:));
    estimate_weightmatrix(i,:)=esti_wm_good(i,:)./maxe;
    %estimate_weightmatrix(i,:)=esti_wm_good(i,:)./1e3;
end
    

save wm;
