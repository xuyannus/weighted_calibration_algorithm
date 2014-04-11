%This file is the code to configure the setting of estimate Wh, it is differnet from the SPSA setting.
%code by : Ma Wei
%date    : 15.08.2013

%modified by hhm,2sept

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Algorithm Parameters            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iteration = 30; % max number of estimate times, the higher the more precise, but it'll take more time

%the vectors below stands for [ODs cap spddsy rt_choice] 
estimate_part = [1;1;1;1]; %the part in Wh we estimate,1 represent this part exist.
warm_up = 4;%first warm_up interval should be omitted
ratio_nonratio = [0; 1; 1; 1]; %0:non-ratio, 1:ratio
perturb_step_init = [8; 0.1; 0.1; 0.1]; %initial perturbation step size
upper = [10^4; 20; 40; 1]; %the upper bound for the parameters during the calibration in ratio
lower = [10^(-1); 0.1; 0.1; -1]; %the lower bound for the parameters during the calibration in ratio

calibration_config=[1;0];%counts;speed. If you only want to calibrate one, set another 0 %20.08.2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   DynaMIT Parameters              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DynaMIT settings
no_sensors = 58;

%simulation settings
start_int = 1; % start running DynaMIT, e.g., 5:00 is 60
end_int = 11; % last DynaMIT interval to run e.g. 9:55-10:00 is 119
warm_up = 1; % number of warm-up intervals e.g. 2 hours = 2 * 12 = 24

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Estimate                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
threshold = 0.3;
interval_effect=[-1,-1,-1,-1]; % modified by hhm,2sept
% -1 if the parameter affects all intervals; otherwise, value i,i = 0,1,2... means that the parameter affects the current interval as well as the i intervals after the current interval.
% PS: generally, the last three paramters should be set as -1 since they are supposed to be time-independent

