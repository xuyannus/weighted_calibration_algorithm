clear all;

%load modified_wm;
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
n=50;		       %total no. of loss measurements
alpha =.602;
gamma =.101;
A=50;
a= 10*10^(-5)*(A+1)^0.602;
c = 4;

%Start
theta_0_dynamit = x;
theta_0_spsa = ones(paramsPerDay,1);
tmp_x = theta_0_spsa'; 
    
%Initial Objective Value
initial_fn_value = FUNC(theta_0_dynamit,sensor_counts, true, wmatrix,secondorder_all);
%xrmsn = RMSN(x_true,theta_0_dynamit);
%save ./Results/fn_x.dat xrmsn -ascii;

%tmp_x = theta_0_spsa';
%tmp_fn = initial_fn_value;
%save ./Results/fn_theta_0.dat tmp_fn -ascii;
    
%Initialize
x_values = [];
fn_values = [];
fn_path = [];
fn_path = [fn_path; initial_fn_value];
grad_log = [];
deltas = [];
nstart = 0;
grad_reps = 1;

mag_scale = 1; % we scale delta by this percent of parameter magnitude
lossfinalsq=0;          %variable for cum.(over 'cases')squared loss values
lossfinal=0;            %variable for cum. loss values

%Main Loop

theta = theta_0_dynamit;  % Start at seed parameter values

wmatrix_n = wmatrix_n_all;

%generate a vector
init = initial_fn_value;
init_sum = zeros(paramsPerDay,1);
 parfor ii = 1:paramsPerDay
    init_sum(ii,1) = wmatrix(ii, :) * init;
 end
a_ratio = init_sum / sum(initial_fn_value);
av = a * ones(paramsPerDay,1)./ a_ratio;


for k= nstart:nstart+n-1
      if mod(k,10) == 0
          k
      end
    
      ck = c / (k+1)^gamma;
      delta = 2 * round(rand(paramsPerDay,1))-1;
      %deltas = [deltas; (ck.*delta)'];
       
      %save ./Results/deltas.dat deltas -ascii;

      lo = zeros(paramsPerDay,1);
      lo = lo + 0.001;
   
      thetaplus = theta + ck.*delta;
      thetaminus = theta - ck.*delta;

      thetaplus = max(lo, thetaplus);
      thetaminus = max(lo, thetaminus);


       
    ghat = zeros(paramsPerDay,1);
   
    %tmp_fn_grad_reps = []; % Store the fn values for averaging

    for xx = 1:grad_reps 
      

      yplus=FUNC(thetaplus, sensor_counts, true, wmatrix,secondorder_all);
      yminus=FUNC(thetaminus, sensor_counts, true, wmatrix,secondorder_all);


      % Store the two fn values
     % tmp_fn = [yminus yplus];
      %tmp_fn_grad_reps = [tmp_fn_grad_reps; tmp_fn];

      thetadif = (thetaplus - thetaminus);%.*theta_0_dynamit;
      ydiff = yplus - yminus;

      %implement the w-spsa
      %only change
      parfor ii = 1:paramsPerDay
          
          %thisdiff = estimate_weightmatrix(ii, :) * ydiff;
          thisdiff = wmatrix(ii, :) * ydiff;
          ghat(ii,1) = ghat(ii,1) + thisdiff/thetadif(ii,1);
      end

    end % end of reps for grad averaging

   % aa = mean(tmp_fn_grad_reps(:,1:1));
    %bb = mean(tmp_fn_grad_reps(:,2:2));

    %tmp_fn = [aa bb];
    %fn_values = [fn_values; tmp_fn];

    ghat = ghat/grad_reps;
    %ak = av/(k+1+A)^alpha;
    ak= a/(k+1+A)^alpha;
    theta=theta - ak.*ghat;
    theta = max(lo, theta);

    path_y = FUNC(theta, sensor_counts, true, wmatrix,secondorder_all);
    
    % path_x = RMSN(x_true,theta);
   % xrmsn = [xrmsn; path_x];
   % save ./Results/fn_x.dat xrmsn -ascii;

    %fn_path = [fn_path; path_y];
    %save ./Results/fn_path.dat fn_path -ascii;

    
  end % iterations (k = 0:n-1)

  % save current fn values (at theta)

  %save ./Results/x_final.dat theta -ascii;

% Display results: Mean loss value and standard deviation

