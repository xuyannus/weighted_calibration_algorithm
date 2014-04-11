%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Algorithm Parameters            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = 30; %max number of algorithm iterations
cut = 100; %cut the iteration into two parts
window_len = 7;
%the vectors below stands for [ODs cap spddsy rt_choice] 
wspsa_selection = [1; 1; 1; 1]; %0:spsa, 1:wspsa(only wh), 2:wspsa(wh before cut,wc after cut), 3:wspsa(wh before cut,wc+wh after cut)
perturb_style = [1; 1; 1; 0]; %0:fixed perturbation, 1:random perturbation
iteration_style = [0; 0; 0; 0]; % 0:shifted mode, 1:step length mode
ratio_nonratio = [0; 1; 1; 0]; %0:non-ratio, 1:ratio
perturb_step_init = [20; 0.1; 0.1; 0]; %initial perturbation step size
perturb_step_min = [0; 0; 0; 0]; %minimum perturbation step size
perturb_reduce_speed = [1.2; 1.5; 1.5; 1.2]; %the speed to reduce the step size if there's no improvement
%Note: if you don't want to calibrate something, just set the upper and lower bounds to 1
calibration_config=[1;0];%counts;speed. If you only want to calibrate one, set another 0 %20.08.2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   SPSA      Parameters            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
upper = [1000; 80; 80; 1]; %the upper bound for the parameters during the calibration in ratio
lower = [0.1; 0.1; 0.1; -1]; %the lower bound for the parameters during the calibration in ratio
amplitude = [0.2,0.5];
alpha = .602;
gamma = .101;
A = 50;
spddsy_a = [10 ; 0.1 ; 1 ; 0.1 ; 1 ; 0.01];
all_a = [1*10^(-4);1*10^(-6);5*10^(-5) * spddsy_a;0] .* (A+1)^0.602;
c = 4;
percentage = 0.2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   DynaMIT Parameters              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DynaMIT settings
%by hhm,13aug
no_sensors = 58;
%simulation settings
start_int = 1;
end_int = 11;
warm_up = 1;

