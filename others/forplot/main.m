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
window = 2;

%Call configure.m to set parameter values
configure;
config = [start_int end_int warm_up];

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

