function CHANGEPARAMETERS(Y)
% THIS FUNCTION WRITES THE NEW SET OF VALUES TO PARAMETER FILE

% Write the parameter value vectors into the respective directories.

% Call C++ scripts to read the vectors and insert them into 
% the corresponding input files for each day.

%modified by MaWei,16.08.2013
%simplification
global no_ODs           % # OD pairs
global no_intervals     % # Time intervals
global no_segments      % # Segments
global no_groups        % # Segment groups
global no_other_params  % # other model params
global demand_factor    % # intervals per hour
global counter_glob;


global paramsPerDay     % # parameters per day

global main_dir

no_ODs
no_intervals
no_segments
no_groups
no_other_params
demand_factor
paramsPerDay

  cd DynaMIT


    demand_params = no_ODs*no_intervals

    save_data = Y(1:demand_params);
    save_data = [no_ODs; no_intervals; demand_factor; save_data];
    save OD_vector.dat save_data -ascii;

    save_data = Y(demand_params+1:demand_params+no_segments);
    save_data = [no_segments; save_data];
    save cap_vector.dat save_data -ascii; 

%    save_data = tmp_vec(demand_params+no_segments+1:paramsPerDay);
    save_data = Y(demand_params+no_segments+1:paramsPerDay-no_other_params);
    save spddsy_vector.dat save_data -ascii;

    save_data = Y(paramsPerDay-no_other_params+1:paramsPerDay);
    save rt_choice.dat save_data -ascii;


  % Insert parameters into input files

    system('./insert_demand');
    % system('../insert_capacities');
    system('./insert_supply_params_all');
    %system('./insert_incident_factor');
    % system('rm -f BehavioralParameters.dat');
    % system('cp BehavioralParameters_backup.dat BehavioralParameters.dat');
    system('./insert_rt_choice');

    system('rm -f demand.dat');
    system('rm -f supplyparam.dat');
    %system('rm -f incident.dat');
    system('rm -f BehavioralParameters.dat');


    system('mv demand_new.dat demand.dat');
    system('mv supplyparam_new.dat supplyparam.dat');
    %system('mv incident_new.dat incident.dat');
    system('mv BehavioralParameters_new.dat BehavioralParameters.dat');


%str = ['mkdir input_data' int2str(counter_glob)];
%system(str);
%str = ['cp -a demand.dat input_data' int2str(counter_glob) '/'];
%system(str);
%str = ['cp -a supplyparam.dat input_data' int2str(counter_glob) '/'];
%system(str);
%str = ['cp -a spddsy_vector.dat input_data' int2str(counter_glob) '/'];
%system(str);
%str = ['cp -a cap_vector.dat input_data' int2str(counter_glob) '/'];
%system(str);
%str = ['cp -a BehavioralParameters.dat input_data' int2str(counter_glob) '/'];
%system(str);

cd ..
    
 
% --------------------------------------------------------
% Old code for MITSIM calibration
% --------------------------------------------------------

%fid = fopen('paralib.dat','r');
%fid1 = fopen('paralib3.dat','w');

%% Route-Choice Beta
%for i = 1: (line_no(1)+1)
%    tline = fgetl(fid);
%    a = sscanf(tline,'%c');
%    fprintf(fid1,'%s',a);
%    fprintf(fid1,'\n');
%end
%tline = fgetl(fid);    
%r = str2num(tline);
%fprintf(fid1,'%8.1f%13.3f',r(1),value(1));
%fprintf(fid1,'\n');
%tline = fgetl(fid);
%r = str2num(tline);
%fprintf(fid1,'%8.1f%13.3f',r(1),value(2));
%fprintf(fid1,'\n');

%% Freeway Bias
%for i = 1:(line_no(2) - line_no(1) - 4)
%    tline = fgetl(fid);
%    a = sscanf(tline,'%c');
%    fprintf(fid1,'%s',a);
%    fprintf(fid1,'\n');
%end
%tline = fgetl(fid);
%fprintf(fid1,'[Freeway Bias]      = %1.3f	# Travel time factor',value(3));
%fprintf(fid1,'\n');

%% CF Kazi parameter 
%for i = (line_no(2)): (line_no(3))
%    tline = fgetl(fid);
%    a = sscanf(tline,'%c');
%    fprintf(fid1,'%s',a);
%    fprintf(fid1,'\n');
%end
%tline = fgetl(fid);
%r = sscanf(tline,'%f');
%fprintf(fid1,'     %2.3f %2.3f %2.3f %2.3f %2.3f #0.825 # acc 0.0225 (original alpha)',value(4),r(2),r(3),r(4),r(5));
%fprintf(fid1,'\n');
%tline = fgetl(fid);
%r = sscanf(tline,'%f');
%fprintf(fid1,'     %2.3f %2.3f %2.3f %2.3f %2.3f #0.802 # dec',value(5),r(2),r(3),r(4),r(5));
%fprintf(fid1,'\n');

%% copying the rest paralib file
%while ~(feof(fid))
%    tline = fgetl(fid)
%    a = sscanf(tline,'%c');
%    fprintf(fid1,'%s',a);
%    fprintf(fid1,'\n');
%end
%fclose(fid);
%fclose(fid1);
%!mv -f paralib3.dat paralib.dat
