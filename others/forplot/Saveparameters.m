%This code will copy the parameter to different files as a record, it's easy.
%By Ma Wei,15,08,2013

function Saveparameters(Y)

global no_ODs           % # OD pairs
global no_intervals     % # Time intervals
global no_segments      % # Segments
global no_groups        % # Segment groups
global no_other_params  % # other model params
global demand_factor    % # intervals per hour
global paramsPerDay

global counter_glob;

cd parameter_record
str=['mkdir -p global' int2str(counter_glob)];
system(str);

demand_params = no_ODs*no_intervals;

%for OD
save_data = Y(1:demand_params);
save_data = [no_ODs; no_intervals; demand_factor; save_data];
str=['save global' int2str(counter_glob) '/OD_vector.dat save_data -ascii;'];
eval(str);

%for cap
save_data = Y(demand_params+1:demand_params+no_segments);
save_data = [no_segments; save_data];
str=['save global' int2str(counter_glob) '/cap_vector.dat save_data -ascii;'];
eval(str);

%for spddsy
save_data = Y(demand_params+no_segments+1:paramsPerDay-no_other_params);
str=['save global' int2str(counter_glob) '/spddsy_vector.dat save_data -ascii;'];
eval(str);

%for rt
save_data = Y(paramsPerDay-no_other_params+1:paramsPerDay);
str =['save global' int2str(counter_glob) '/rt_choice.dat save_data -ascii;'];
eval(str);

cd ..
