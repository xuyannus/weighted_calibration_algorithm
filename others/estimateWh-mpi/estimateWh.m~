%This code is made for estimate Wh in W-SPSA, it is the first step to calibrate DynaMIT using W-SPSA.
%coded by : Ma Wei
%date     : 2013.08.15
%Rewrite it to a function and input the starting interval and during time
%22.08.2013

function estimateWh(num, start, duration)

global no_sensors
global no_ODs
global no_intervals
global no_segments
global no_other_params
global demand_factor
global paramsPerDay
global calibration_config;
global counter_glob %current number of DynaMIT runs

counter_glob = 2 * start + 1;

%configure
estimate_configure;
config = [start_int, end_int, warm_up];

%load theta
cd initial

load OD_vector.dat;
load cap_vector.dat;
load spddsy_vector.dat;
load rt_choice.dat;
cd ..

%give original data
no_ODs = OD_vector(1);
no_intervals = OD_vector(2);
demand_factor = OD_vector(3);
od_seed = OD_vector(4:length(OD_vector));
cap_seed = cap_vector(2:length(cap_vector));
no_segments = cap_vector(1);
spddsy_seed = spddsy_vector;
rtchoice_param = rt_choice;
no_other_params = length(rtchoice_param);

paramsPerDay = no_ODs * no_intervals + no_segments + 6 * no_segments + no_other_params;

%combine all the value and set as the theta we want to perturb
theta_to_be_perturb = [od_seed; cap_seed; spddsy_seed; rtchoice_param];

%lower bound and upper bound
%Lower bound
lb = [];
lb = [lb; (theta_to_be_perturb(1:no_ODs*no_intervals)+0.1)*lower(1,1)]; %OD
lb = [lb; theta_to_be_perturb(no_ODs*no_intervals+1:no_ODs*no_intervals+no_segments)*lower(2,1)]; %capacity
lb = [lb; theta_to_be_perturb(no_ODs*no_intervals+no_segments+1:paramsPerDay-no_other_params)*lower(3,1)]; %spddsy
lb = [lb; ones(no_other_params,1)*lower(4,1)]; %behavior

%Upper bound
ub = [];
ub = [ub; (theta_to_be_perturb(1:no_ODs*no_intervals)+0.1)*upper(1,1)]; %OD
ub = [ub; theta_to_be_perturb(no_ODs*no_intervals+1:no_ODs*no_intervals+no_segments)*upper(2,1)]; %capacity
ub = [ub; theta_to_be_perturb(no_ODs*no_intervals+no_segments+1:paramsPerDay-no_other_params).*upper(3,1)];     %spddsy
ub = [ub; ones(no_other_params,1).*upper(4,1)];%behavior

%till now, we have load all the setting we need to perturb the theta
%let do the estimation

%set data
theta = theta_to_be_perturb; 
od=od_seed;
cap=cap_seed;
spddsy=spddsy_seed;
rt=rtchoice_param;
perturb_step = perturb_step_init;

%let's go loop
for k=start:start+duration
  %perturbation vector decided by perturbation style and step size
  %for OD
  if estimate_part(1,1)==0
    delta_od = zeros(no_ODs * no_intervals,1);
  else
    delta_od = 2 * round(rand(no_ODs * no_intervals,1)) - 1;
  end
  delta_od = delta_od * perturb_step(1,1);

  %for cap
  if estimate_part(2,1)==0
    delta_cap = zeros(no_segments,1);
  else
    delta_cap = 2 * round(rand(no_segments,1)) - 1;
  end
  delta_cap = delta_cap * perturb_step(2,1);

  %for spddsy
  if estimate_part(3,1)==0
    delta_spddsy = zeros(no_segments * 6,1);
  else
    delta_spddsy = 2 * round(rand(no_segments * 6,1)) - 1;
  end
  delta_spddsy = delta_spddsy * perturb_step(3,1);

  %for route-choice
  if estimate_part(4,1)==0
    delta_rt = zeros(no_other_params,1);
  else
    delta_rt = 2 * round(rand(no_other_params,1)) - 1;
  end
  delta_rt = delta_rt * perturb_step(4,1);

%calculate plus and minus
  %for od
  if ratio_nonratio(1,1) == 0
    od_plus = od + delta_od;
    od_minus = od - delta_od;
  else
    od_plus = od .* (1 + delta_od);
    od_minus = od .* (1 - delta_od);
  end

  %for cap
  if ratio_nonratio(2,1) == 0
    cap_plus = cap + delta_cap;
    cap_minus = cap - delta_cap;
  else
    cap_plus = cap .* (1 + delta_cap);
    cap_minus = cap .* (1 - delta_cap);
  end  
 
  %for spddsy
  if ratio_nonratio(3,1) == 0
    spddsy_plus = spddsy + delta_spddsy;
    spddsy_minus = spddsy - delta_spddsy;
  else
    spddsy_plus = spddsy .* (1 + delta_spddsy);
    spddsy_minus = spddsy .* (1 - delta_spddsy);
  end   

  %for route-choice
  if ratio_nonratio(4,1) == 0
    rt_plus = rt + delta_rt;
    rt_minus = rt - delta_rt;
  else
    rt_plus = rt .* (1 + delta_rt);
    rt_minus = rt .* (1 - delta_rt);
  end  


%ensure the theta do not exceed the bound
  %Boundaries
  dynamit_plus = [od_plus; cap_plus; spddsy_plus; rt_plus];
  dynamit_minus = [od_minus; cap_minus; spddsy_minus; rt_minus];
  dynamit_plus = min(dynamit_plus, ub);
  dynamit_plus = max(dynamit_plus, lb);
  dynamit_minus = min(dynamit_minus, ub);
  dynamit_minus = max(dynamit_minus, lb);

%Run DynaMIT twice
  yplus = FUNC(dynamit_plus, config, true, num);
  yminus = FUNC(dynamit_minus,config, false, num);  

%Get the diff
  ydiff = yplus - yminus; %squared error vector
  thetadiff = dynamit_plus - dynamit_minus;

%save it
  cd iteration_record
  str=['mkdir -p iteration' int2str(k)];
  system(str);
  str=['save iteration' int2str(k) '/ydiff.dat ydiff -ascii;'];
  eval(str);
  str=['save iteration' int2str(k) '/yplus.dat yplus -ascii;'];
  eval(str);
  str=['save iteration' int2str(k) '/yminus.dat yminus -ascii;'];
  eval(str);
  str=['save iteration' int2str(k) '/thetaplus.dat dynamit_plus -ascii;'];
  eval(str);
  str=['save iteration' int2str(k) '/thetaminus.dat dynamit_plus -ascii;'];
  eval(str);
  str=['save iteration' int2str(k) '/thetadiff.dat thetadiff -ascii;'];
  eval(str);
  cd ..

end
disp('This Process Perturbation Finished!')
%disp('Start to Estimate.')
%LoadandEstimate;
