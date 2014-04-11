%Matlab code for the new calibration algorithm.
%hhm,15aug 2013

%modified by Ma Wei, 16.08.2013
%19.08.2013 Mawei
%Add the old_record, if the RMSN doesn't drop, i will shorten the step and drop the current value.

clc
clear all
system('./clean')
global calibration_config;
global no_sensors;
global no_ODs;
global no_intervals;
global no_segments;
global no_other_params;
global demand_factor;
global paramsPerDay;
global counter_glob; %current number of DynaMIT runs
global weight_percentage;
global config_for_five;
global window;

counter_glob = 0;

%Call configure.m to set parameter values
configure;
config = [start_int end_int warm_up];
window = window_len;

%load input information from DynaMIT directory
cd initial;
load OD_vector.dat;
load cap_vector.dat;
load spddsy_vector.dat;
load rt_choice.dat;
cd ..
%pre-set parameters for calibration
%demand
no_ODs = OD_vector(1);
no_intervals = OD_vector(2);
demand_factor = OD_vector(3);
od_seed = OD_vector(4:length(OD_vector));
%supply
no_segments = cap_vector(1);
cap_seed = cap_vector(2:length(cap_vector));
%speed density
spddsy_seed = spddsy_vector;
%route choice
rtchoice_param = rt_choice; 
no_other_params = length(rtchoice_param);
%number of all parameters
paramsPerDay = no_ODs * no_intervals + no_segments + 6 * no_segments + no_other_params; % nubmer of route choice parameters

%set starting value for theta and y
theta_0_dynamit = [od_seed; cap_seed; spddsy_seed; rtchoice_param];
initial_fn_vector = FUNC(theta_0_dynamit,config,true); %the squared error vector
last_y = initial_fn_vector; 
initial_fn_value = sum(initial_fn_vector);

%%
g_record = [];
rmsns = [];
thetas = [];
fn_path = [];
fh_path = [fn_path; initial_fn_value];
weight_percentage = ones(paramsPerDay, no_sensors * (end_int-start_int-warm_up)) .* percentage; 

%upper and lower bound
lb = [];
%lb = [lb; (theta_0_dynamit(1:no_ODs*no_intervals)+0.1)*lower(1,1)]; %OD
%lb = [lb; theta_0_dynamit(no_ODs*no_intervals+1:no_ODs*no_intervals+no_segments)*lower(2,1)]; %capacity
%lb = [lb; theta_0_dynamit(no_ODs*no_intervals+no_segments+1:paramsPerDay-no_other_params)*lower(3,1)]; %spddsy
%lb = [lb; ones(no_other_params,1)*lower(4,1)]; %behavior
ub = [];
%ub = [ub; (theta_0_dynamit(1:no_ODs*no_intervals)+0.1)*upper(1,1)]; %OD
%ub = [ub; theta_0_dynamit(no_ODs*no_intervals+1:no_ODs*no_intervals+no_segments)*upper(2,1)]; %capacity
%ub = [ub; theta_0_dynamit(no_ODs*no_intervals+no_segments+1:paramsPerDay-no_other_params)*upper(3,1)];%spddsy
%ub = [ub; ones(no_other_params,1)*upper(4,1)];%behavior
lb = [lb; ones(no_ODs * no_intervals,1) * lower(1,1)]; %OD
lb = [lb; ones(no_segments,1) * lower(2,1)]; %capacity
lb = [lb; ones(6 * no_segments,1) * lower(3,1)]; %spddsy
lb = [lb; ones(no_other_params,1) * lower(4,1)]; %behavior

ub = [ub; ones(no_ODs * no_intervals,1) * upper(1,1)];
ub = [ub; ones(no_segments,1) * upper(2,1)]; %capacity
ub = [ub; ones(6 * no_segments,1) * upper(3,1)];%spddsy
ub = [ub; ones(no_other_params,1) * upper(4,1)];%behavior

%load weight matrix
load wh.dat

%load purturbation step size and advance step size
perturb_step = perturb_step_init;

%initializing parameters to be calibrated
dynamit = theta_0_dynamit;
ods = od_seed;
caps = cap_seed;
spddsys = spddsy_seed;
rts = rtchoice_param;

%start calibration loop
wc = wh;

if wspsa_selection' * wspsa_selection == 0 % if all elements in wspsa_selection equal zero
else
  [od_wh,cap_wh,spddsy_wh,rt_wh] = seperate_SparseMatrix(wh,no_ODs * no_intervals,no_segments,6 * no_segments,no_other_params);
  [od_wc,cap_wc,spddsy_wc,rt_wc] = seperate_SparseMatrix(wc,no_ODs * no_intervals,no_segments,6 * no_segments,no_other_params);
end

for MainLoopIndex = 1:n
  %generating perburbation directions and step size
  if perturb_style(1,1) == 0 %fixed perturbation, all in a same direction
    delta_ods = ones(no_ODs * no_intervals,1) .* perturb_step(1,1);
  else
    delta_ods = 2 * round(rand(no_ODs * no_intervals,1)) - 1; %random perturbation directions
    delta_ods = delta_ods * perturb_step(1,1);
  end
  %for cap
  if perturb_style(2,1) == 0 %fixed perturbation, all in a same direction
    delta_cap = ones(no_segments,1) * perturb_step(2,1);
  else
    delta_cap = 2 * round(rand(no_segments,1)) - 1; %random perturbation directions
    delta_cap = delta_cap * perturb_step(2,1);
  end
  %for spddsy
  if perturb_style(3,1) == 0 %fixed perturbation, all in a same direction
    delta_spddsy = ones(no_segments * 6,1) * perturb_step(3,1);
  else
    delta_spddsy = 2 * round(rand(no_segments * 6,1)) - 1; %random perturbation directions
    delta_spddsy = delta_spddsy * perturb_step(3,1);
  end
  %for rtchoice
  if perturb_style(4,1) == 0 %fixed perturbation, all in a same direction
    delta_rt = ones(no_other_params,1) * perturb_step(4,1);
  else
    delta_rt = 2 * round(rand(no_other_params,1)) - 1; %random perturbation directions
    delta_rt = delta_rt * perturb_step(4,1);
  end

  %exercising perburbation over parameters(od,cap,spddsy,rt)
  %for ods
  if ratio_nonratio(1,1) == 0 % non-ratio
    ods_plus = ods + delta_ods;
    ods_minus = ods - delta_ods;
  else % ratio
    ods_plus = ods .* (1 + delta_ods);
    ods_minus = ods .* (1 - delta_ods);
  end
  ods_plus = round(ods_plus);
  ods_minus = round(ods_minus);
  %for caps
  if ratio_nonratio(2,1) == 0 % non-ratio
    caps_plus = caps + delta_cap;
    caps_minus = caps - delta_cap;
  else % ratio
    caps_plus = caps .* (1 + delta_cap);
    caps_minus = caps .* (1 - delta_cap);
  end
  %for spddsys
  if ratio_nonratio(3,1) == 0 % non-ratio
    spddsys_plus= spddsys + delta_spddsy;
    spddsys_minus = spddsys - delta_spddsy;
  else % ratio
    spddsys_plus = spddsys .* (1 + delta_spddsy);
    spddsys_minus = spddsys .* (1 - delta_spddsy);
  end
  %for rt parameters
  if ratio_nonratio(4,1) == 0 % non-ratio
    rts_plus= rts + delta_rt;
    rts_minus = rts - delta_rt;
  else % ratio
    rts_plus = rts .* (1 + delta_rt);
    rts_minus = rts .* (1 - delta_rt);
  end
  
  %upper and lower bounds
  dynamit_plus = [ods_plus; caps_plus; spddsys_plus; rts_plus];
  dynamit_minus = [ods_minus; caps_minus; spddsys_minus; rts_minus];
  dynamit_plus = min(dynamit_plus, ub);
  dynamit_plus = max(dynamit_plus, lb);
  dynamit_minus = min(dynamit_minus, ub);
  dynamit_minus = max(dynamit_minus, lb);

  %running dynamit twice
  yplus = FUNC(dynamit_plus,config, false);  
  yminus = FUNC(dynamit_minus,config, false);

  %generating new vectors
  ydiff = yplus - yminus;
  g_record=[g_record;ydiff'];
  dynamitdiff = dynamit_plus - dynamit_minus;
  ak = all_a ./ (MainLoopIndex + A + 1)^alpha;
  i = 1;

  % od part begins
  ods_old=ods;%By MaWei
  switch (wspsa_selection(1,1))
  case 0 % spsa
    thisdiff = sum(ydiff,1);
    j = i - 1;
    while (i <= no_ODs * no_intervals)
      if dynamitdiff(i) == 0
        thisdiff = 0;
      else
        switch (iteration_style(1,1))
        case 0
          if thisdiff < 0
            ods(i - j) = dynamit_plus(i);
          else
            ods(i - j) = dynamit_minus(i);
          end
        case 1
          ods(i - j) = ods(i - j) - ak(1,1) * (thisdiff / dynamitdiff(i));
        endswitch;
      end
      i = i + 1;
    end
  otherwise % wspsa
    switch (wspsa_selection(1,1))
    case 1
      WM_od = od_wh;
    case 2
      if MainLoopIndex < cut
        WM_od = od_wh;
      else
        WM_od = od_wc;
      end
    case 3
      if MainLoopIndex < cut
        WM_od = od_wh;
      else
        WM_od = merge_SparseMatrix(od_wh,od_wc);
      end
    endswitch;
    cur_WMIndex = 1;
    max_WMIndex = size(WM_od,1);

    j = i - 1;
    while (i <= no_ODs * no_intervals)
      i = WM_od(cur_WMIndex,1);
      total_diff = 0;
      while (cur_WMIndex <= max_WMIndex && WM_od(cur_WMIndex,1) == i)
        y_index = WM_od(cur_WMIndex,2);
        total_diff = total_diff + ydiff(y_index,1) * WM_od(cur_WMIndex,3);
        cur_WMIndex = cur_WMIndex + 1;
      end

      thisdiff = total_diff;
      if dynamitdiff(i) == 0
        thisdiff = 0;
      else
        switch (iteration_style(1,1))
        case 0 % shifted mode
          if thisdiff < 0
            ods(i - j) = dynamit_plus(i);
          else
            ods(i - j) = dynamit_minus(i);
          end
        case 1 % step length mode
          ods(i - j) = ods(i - j) - ak(1,1) * (thisdiff / dynamitdiff(i));
        endswitch;
      end

      % guards: ensure safety
      if cur_WMIndex <= max_WMIndex
        %last_WMIndex = cur_WMIndex;
      else
        i = no_ODs * no_intervals + 1;
      end
    end
  endswitch;
  ods = round(ods);
  % od part ends


  % cap part begins
  caps_old=caps;%By MaWei
  switch (wspsa_selection(2,1))
  case 0 % spsa
    thisdiff = sum(ydiff);
    j = i - 1;
    while (i <= no_ODs * no_intervals + no_segments)
      if dynamitdiff(i) == 0
        thisdiff = 0;
      else
        switch (iteration_style(2,1))
        case 0
          if thisdiff < 0
            caps(i - j) = dynamit_plus(i);
          else
            caps(i - j) = dynamit_minus(i);
          end
        case 1
          caps(i - j) = caps(i - j) - ak(2,1) * (thisdiff / dynamitdiff(i));
        endswitch;
      end
      i = i + 1;
    end
  otherwise % wspsa
    switch (wspsa_selection(2,1))
    case 1
      WM_cap = cap_wh;
    case 2
      if MainLoopIndex < cut
        WM_cap = cap_wh;
      else
        WM_cap = cap_wc;
      end
    case 3
      if MainLoopIndex < cut
        WM_cap = cap_wh;
      else
        WM_cap = merge_SparseMatrix(cap_wh,cap_wc);
      end
    endswitch;
    cur_WMIndex = 1;
    max_WMIndex = size(WM_cap,1);

    j = i - 1;
    while (i <= no_ODs * no_intervals + no_segments)
      i = WM_cap(cur_WMIndex,1);
      total_diff = 0;
      while (cur_WMIndex <= max_WMIndex && WM_cap(cur_WMIndex,1) == i)
        y_index = WM_cap(cur_WMIndex,2);
        total_diff = total_diff + ydiff(y_index,1) * WM_cap(cur_WMIndex,3);
        cur_WMIndex = cur_WMIndex + 1;
      end

      thisdiff = total_diff;
      if dynamitdiff(i) == 0
        thisdiff = 0;
      else
        switch (iteration_style(2,1)) 
        case 0 % shifted mode
          if thisdiff < 0
            caps(i - j) = dynamit_plus(i);
          else
            caps(i - j) = dynamit_minus(i);
          end
        case 1 % step length mode
          caps(i - j) = caps(i - j) - ak(2,1) * (thisdiff / dynamitdiff(i));
        endswitch;
      end

      % guards: ensure safety
      if cur_WMIndex <= max_WMIndex
        %last_WMIndex = cur_WMIndex;
      else
        i = no_ODs * no_intervals + no_segments + 1;
      end
    end
  endswitch;
  % cap part ends


  % spddsy part begins
  spddsys_old=spddsys;%By MaWei
  switch (wspsa_selection(3,1))
  case 0 % spsa
    thisdiff = sum(ydiff);
    j = i - 1;
    while (i <= no_ODs * no_intervals + no_segments + 6 * no_segments)
      if dynamitdiff(i) == 0
        thisdiff = 0;
      else
        switch (iteration_style(3,1))
        case 0
          if thisdiff < 0
            spddsys(i - j) = dynamit_plus(i);
          else
            sdpdsys(i - j) = dynamit_minus(i);
          end
        case 1
          ak_index_spddsy = mod(i - j - 1, 6) + 1;
          ak_index_spddsy = ak_index_spddsy + 2;
          spddsys(i - j) = spddsys(i - j) - ak(ak_index_spddsy,1) * (thisdiff / dynamitdiff(i));
        endswitch;
      end
      i = i + 1;
    end
  otherwise % wspsa
    switch (wspsa_selection(3,1))
    case 1
      WM_spddsy = spddsy_wh;
    case 2
      if MainLoopIndex < cut
        WM_spddsy = spddsy_wh;
      else
        WM_spddsy = spddsy_wc;
      end
    case 3
      if MainLoopIndex < cut
        WM_spddsy = spddsy_wh;
      else
        WM_spddsy = merge_SparseMatrix(spddsy_wh,spddsy_wc);
      end
    endswitch;
    cur_WMIndex = 1;
    max_WMIndex = size(WM_spddsy,1);

    j = i - 1;
    while (i <= no_ODs * no_intervals + no_segments + 6 * no_segments)
      i = WM_spddsy(cur_WMIndex,1); 
      total_diff = 0;
      while (cur_WMIndex <= max_WMIndex && WM_spddsy(cur_WMIndex,1) == i)
        y_index = WM_spddsy(cur_WMIndex,2);
        total_diff = total_diff + ydiff(y_index,1) * WM_spddsy(cur_WMIndex,3);
        cur_WMIndex = cur_WMIndex + 1;
      end

      thisdiff = total_diff;
      if dynamitdiff(i) == 0
        thisdiff = 0;
      else
        switch (iteration_style(3,1))
        case 0
          if thisdiff < 0
            spddsys(i - j) = dynamit_plus(i);
          else
            sdpdsys(i - j) = dynamit_minus(i);
          end
        case 1
          ak_index_spddsy = mod(i - j - 1, 6) + 1;
          ak_index_spddsy = ak_index_spddsy + 2;
          spddsys(i - j) = spddsys(i - j) - ak(ak_index_spddsy,1) * (thisdiff / dynamitdiff(i));
        endswitch;
      end

      % guards: ensure safety
      if cur_WMIndex <= max_WMIndex
        %last_WMIndex = cur_WMIndex;
      else
        i = no_ODs * no_intervals + no_segments + 6 * no_segments + 1;
      end
    end
  endswitch;
  % spddsy part ends


  % rt part begins
  rts_old=rts;%By MaWei
  switch (wspsa_selection(4,1))
  case 0 % spsa
    thisdiff = sum(ydiff);
    j = i - 1;
    while (i <= no_ODs * no_intervals + no_segments + 6 * no_segments + no_other_params)
      if dynamitdiff(i) == 0
        thisdiff = 0;
      else
        switch (iteration_style(4,1))
          case 0 % shifted mode
            % do not modify rt
          case 1 % step length mode
            %rts(i - j) = rts(i - j) - ak(9,1) * (thisdiff / dynamitdiff(i));
            % do not modify rt
          endswitch;
      end
      i = i + 1;
    end
  otherwise % wspsa
    switch (wspsa_selection(4,1))
    case 1
      WM_rt = rt_wh;
    case 2
      if MainLoopIndex < cut
        WM_rt = rt_wh;
      else
        WM_rt = rt_wc;
      end
    case 3
      if MainLoopIndex < cut
        WM_rt = rt_wh;
      else
        WM_rt = merge_SparseMatrix(rt_wc,rt_wh);
      end
    endswitch;
    cur_WMIndex = 1;
    max_WMIndex = size(WM_rt,1);

    j = i - 1;
    while (i <= no_ODs * no_intervals + no_segments + 6 * no_segments + no_other_params)
      i = WM_rt(cur_WMIndex,1);
      total_diff = 0;
      while (cur_WMIndex <= max_WMIndex && WM_rt(cur_WMIndex,1) == i)
        y_index = WM_rt(cur_WMIndex,2);
        total_diff = total_diff + ydiff(y_index,1) * WM_rt(cur_WMIndex,3);
        cur_WMIndex = cur_WMIndex + 1;
      end

      thisdiff = total_diff;
      if dynamitdiff(i) == 0
        thisdiff = 0;
      else
        switch (iteration_style(4,1))
        case 0 % shifted mode
          % do not modify rt
        case 1 % step length mode
          %rts(i - j) = rts(i - j) - ak(9,1) * (thisdiff / dynamitdiff(i));
          % do not modify rt
        endswitch;
      end

      % guards: ensure safety
      if cur_WMIndex <= max_WMIndex
        %last_WMIndex = cur_WMIndex;
      else
        i = paramsPerDay + 1;
      end
    end
  endswitch;
  % rt part ends


  % upper and lower bounds 
  dynamit = [ods;caps;spddsys;rts];
  dynamit = min(dynamit, ub);
  dynamit = max(dynamit, lb);
  str = ['mkdir -p iteration_record/iteration' int2str(MainLoopIndex) ';'];
  system(str);
  str = ['save ./iteration_record/iteration' int2str(MainLoopIndex) '/theta.dat dynamit -ascii;'];
  eval(str);
  thetas = [thetas; dynamit'];


  % generate path_y
  path_y = FUNC(dynamit,config, true);
  rmsns = [rmsns; path_y'];
  fn_path = [fn_path;sum(path_y)];
  %save ./results/fn_path.dat fn_path -ascii;

  %see if the RMSN drop and shorten the step depend on situation
  %By Ma Wei
  cd results
  load fn_RMSN_counts.dat;
  cd ..

  len_fnRMSN = size(fn_RMSN_counts,1); % by hhm,19aug
  if fn_RMSN_counts(len_fnRMSN,2) >= fn_RMSN_counts(len_fnRMSN - 1,2)
    ods=ods_old;
    caps=caps_old;
    spddsys=spddsys_old;
    rts=rts_old;
    if iteration_style(1,1) == 0
      perturb_step(1,1) = perturb_step(1,1)/perturb_reduce_speed(1,1);
      perturb_step(1,1) = max(perturb_step(1,1),perturb_step_min(1,1));
    end
    if iteration_style(2,1) == 0
      perturb_step(2,1) = perturb_step(2,1)/perturb_reduce_speed(2,1);
      perturb_step(2,1) = max(perturb_step(2,1),perturb_step_min(2,1));
    end
    if iteration_style(3,1) == 0
      perturb_step(3,1) = perturb_step(3,1)/perturb_reduce_speed(3,1);
      perturb_step(3,1) = max(perturb_step(3,1),perturb_step_min(3,1));
    end
    if iteration_style(4,1) == 0
      perturb_step(4,1) = perturb_step(4,1)/perturb_reduce_speed(4,1);
      perturb_step(4,1) = max(perturb_step(4,1),perturb_step_min(4,1));
    end
  end
    
  % generate wc for the next iteration if iteration times is larger than cut
  if MainLoopIndex > cut
    wc = generate_Wc(wc, wh, rmsns, thetas, g_record, amplitude);
    [od_wc,cap_wc,spddsy_wc,rt_wc] = seperate_SparseMatrix(wc,no_ODs * no_intervals,no_segments,6 * no_segments,no_other_params);
  end

end %iterations (MainLoopIndex = 1:n)
