%Objective Function Evaluation
%By Ma Wei, 15,08,2012
%source from lulu's code

function y = FUNC(X, config, flag)

global calibration_config;
%global mainoutput
global no_sensors     % # sensors
global no_ODs          % # OD pairs
global no_intervals    % # Time intervals
global no_segments     % # Segments
global no_groups       % # Segment groups
global no_other_params % # other parameters
global paramsPerDay    % # parameters to be calibrated per day of data
global day
global counter_glob;

global main_dirde

counter_glob = counter_glob + 1

%simulation settings
start_int = config(1,1);
end_int = config(1,2);
warm_up = config(1,3);

%load bad sensor ids
cd initial
sensor_condition = ones(no_sensors * no_intervals,1); % 1 for good sensor and 0 for bad sensor
if exist("bad_sensor_id.dat",'file')
     load bad_sensor_id.dat;
     bad_sensor_id = bad_sensor_id + 1;
     no_bad_sensors = length(bad_sensor_id);
     for j = 1:no_bad_sensors
          bad_sensor = bad_sensor_id(j,1);
          sensor_condition(bad_sensor,1) = 0;
     end
else
  bad_sensor_id=[];
end
cd ..

%write the new parameters into file
CHANGEPARAMETERS(X); %it will goto the DynaMIT file automatically

%save
save_Parameters(X);

%Run the DynaMIT
cd DynaMIT
str = ['./backupToDir'];
system(str);
system('./DynaMIT_P dtaparam.dat');


dev=[];
if calibration_config(1)==1
  %read count and stat
  sim_counts = [];
  counts_seed =[];
  sensor_counts =[];
  %load simulated sensor counts
  %load
  for i = start_int+warm_up+1 : end_int
    str = ['load Sim' int2str(i) '.dat'];
    eval(str);
  end
  %combine
  for i= start_int+warm_up+1 : end_int
    str = ['sim_counts = [sim_counts; Sim' int2str(i) '];'];
    eval(str);   
  end  

  %load observed sensor counts
  load ../initial/sensor_counts.dat;
  sensor_counts = sensor_counts(no_sensors * (start_int + warm_up) + 1 : no_sensors * (end_int),1);

  %Lu: deal with the sensor failures
  for i = 1:size(sensor_counts,1)
    if sensor_counts(i,1) == -1
      sensor_counts(i,1) = 0;
      sim_counts(i,1) = 0;
    end
  end

  %deal with bad sensors
  measure_len = end_int - start_int - warm_up + 1;
  for i = 1:measure_len
    for j = 1:no_sensors
      if sensor_condition(j,1) == 0
        sensor_counts((i-1)*no_sensors + j, 1) = 0;
        sim_counts((i-1)*no_sensors + j, 1) = 0;
      end
    end
  end

  dev = [dev;sensor_counts - sim_counts];
  n1 = length(sensor_counts) - length(bad_sensor_id) * measure_len - sum(sensor_counts== 0);
  RMSN_counts = RMSN(sensor_counts,sim_counts, n1) ;

end

%if there exist speed
if calibration_config(2)==1
  
  interval_len = 5;
  measure_len = end_int - start_int - warm_up + 1;
  system('python rewrite_speed.py');
  cd output
  %load seg_spd_Est_070000-190000.csv;
  cur_spd = csvread('seg_spd_Est_070000-093000.csv');
  spd = cur_spd(2:size(cur_spd,1),2:221);% each line is the spd for each segment in 1 min, the first element of each line is interval id, e.g., 0:05 is 5
  cd ..

  % Load observed speed
  load ../initial/speeds_seed.dat;
  real_speed = speeds_seed((start_int+warm_up)*no_segments+1:end_int*no_segments)  ;

  for cur_int = start_int+warm_up+1:end_int
    flag1 = (cur_int-1) * interval_len + 1;
    flag2 = cur_int * interval_len;
    sim_speed_line(cur_int-(start_int+warm_up),:) = takeaverage(spd(flag1:flag2,:));
  end

    %size(sim_speed_line)
  for cur_int = 1:end_int-(start_int+warm_up)
    for cur_seg = 1:no_segments
      sim_speed((cur_int-1)*no_segments + cur_seg,1) = sim_speed_line(cur_int, cur_seg);
    end
  end

  %deal with the sensor failures about speed
  for i = 1:size(real_speed,1)
    if real_speed(i,1) == -1 || sim_speed(i,1) == 0
      real_speed(i,1) = 0;
      sim_speed(i,1) = 0;
    end
  end

  sim_speed = sim_speed * 1.6093; % convert from mile to kilometer
  dev = [dev;(real_speed - sim_speed) .* 1];
  n2 = length(real_speed) - length(bad_sensor_id) * measure_len - sum(real_speed == 0);
  RMSN_speed = RMSN(real_speed, sim_speed, n2) ;
end

if flag==true
  cd ../results
  %for counts
  if calibration_config(1)==1
    if(counter_glob == 1)
        fn_RMSN_counts = [1 RMSN_counts];
    save fn_RMSN_counts.dat fn_RMSN_counts -ascii;
    else
      load fn_RMSN_counts.dat;
      fn_RMSN_counts = [fn_RMSN_counts ; counter_glob RMSN_counts];
      save fn_RMSN_counts.dat fn_RMSN_counts -ascii;
    end
  end
  %save speed
  if calibration_config(2)==1
    if(counter_glob == 1)
      fn_RMSN_speed = [counter_glob RMSN_speed] ;
      save fn_RMSN_speed.dat fn_RMSN_speed -ascii;
    else
      load fn_RMSN_speed.dat;
      fn_RMSN_speed = [fn_RMSN_speed ; counter_glob RMSN_speed];
      save fn_RMSN_speed.dat fn_RMSN_speed -ascii;
    end
  end      
end
  cd ..


%save counts
cd parameter_record
str=['save global' int2str(counter_glob) '/sim_counts.dat sim_counts -ascii;'];
eval(str);
str=['save global' int2str(counter_glob) '/sim_speed.dat sim_speed -ascii;'];
eval(str);
str=['save global' int2str(counter_glob) '/dev.dat dev -ascii;'];
eval(str);

cd ..
y = dev .^2;
