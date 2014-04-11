clear all;

load wm;

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
n=100;		       %total no. of loss measurements
alpha =.602;
gamma =.101;
A=50;
a=0.05*10^(-7)*(A+1)^0.602;
c = 4;
% modified by HHM, 21 july
p = paramsPerDay; % number of parameters to calibrate
m = no_sen; % number of measurements

%Start
theta_0_dynamit = x;
theta_0_spsa = ones(p,1);
tmp_x = theta_0_spsa'; 
    
%Initial Objective Value
initial_fn_value = FUNC(theta_0_dynamit,sensor_counts, true, wmatrix,secondorder_all);
xrmsn = RMSN(x_true,theta_0_dynamit);
save ./Results/fn_x.dat xrmsn -ascii;

tmp_x = theta_0_spsa';
tmp_fn = initial_fn_value;
save ./Results/fn_theta_0.dat tmp_fn -ascii;
    
%Initialize
x_values = [];
fn_values = [];
fn_path = [];
fn_path = [fn_path; initial_fn_value];
grad_log = [];
deltas = [];
nstart = 0;
grad_reps = 1;

% modified by HHM, 21 july
delta_THETA = zeros(p,1); % theta(k+1)-theta(k)
delta_MEASURE = zeros(m,1); % measurement(k+1)-measurement(k)

% modified by HHM, 21 july
horizon = 10; % horizon size
beta = 0.9; % deteriorate factor

mag_scale = 1; % we scale delta by this percent of parameter magnitude
lossfinalsq=0; %variable for cum.(over 'cases')squared loss values
lossfinal=0; %variable for cum. loss values

%Main Loop

theta = theta_0_dynamit;  % Start at seed parameter values
wmatrix_n = wmatrix_n_all;

% modified by HHM, 21 july
%weight =  (1 + (0.5 * rand(p,m))) .* wmatrix_n;
weight = estimate_weightmatrix;

% modified by HHM, 21 july
%  ERROR = GRAD * DELTA_W
GRAD = zeros(horizon,p); % grad
ERROR = zeros(horizon,m); % ...
DELTA_W = zeros(p,m); % weight(k+1)-beta*weight(k)




for k= nstart:nstart+n-1

    %generate a vector 
% modified by HHM, 21 july
init = initial_fn_value;
init_sum = zeros(p,1);

 parfor ii = 1:p
    init_sum(ii,1) = weight(ii, :) * init;
 end
a_ratio = init_sum / sum(initial_fn_value);
av = a * ones(p,1)./ a_ratio;

      if mod(k,10) == 0
          k
      end
    
      ck = c / (k+1)^gamma;
      delta = 2 * round(rand(p,1))-1;
      deltas = [deltas; (ck.*delta)'];
       
      save ./Results/deltas.dat deltas -ascii;

      lo = zeros(p,1);
      lo = lo + 0.001;
   
      thetaplus = theta + ck.*delta;
      thetaminus = theta - ck.*delta;

      thetaplus = max(lo, thetaplus);
      thetaminus = max(lo, thetaminus);

    ak = av/(k+1+A)^alpha;
       
    ghat = zeros(p,1);
   
    tmp_fn_grad_reps = []; % Store the fn values for averaging

    for xx = 1:grad_reps 
      

      yplus=FUNC(thetaplus, sensor_counts, true, wmatrix,secondorder_all);
      yminus=FUNC(thetaminus, sensor_counts, true, wmatrix,secondorder_all);


      % Store the two fn values
      tmp_fn = [yminus yplus];
      tmp_fn_grad_reps = [tmp_fn_grad_reps; tmp_fn];

      thetadif = (thetaplus - thetaminus);%.*theta_0_dynamit;
      ydiff = yplus - yminus;

      parfor ii = 1:p
          
          thisdiff = weight(ii, :) * ydiff;
          ghat(ii,1) = ghat(ii,1) + thisdiff/thetadif(ii,1);
      end

    end % end of reps for grad averaging

    aa = mean(tmp_fn_grad_reps(:,1:1));
    bb = mean(tmp_fn_grad_reps(:,2:2));

    tmp_fn = [aa bb];
    fn_values = [fn_values; tmp_fn];

    ghat = ghat/grad_reps;

% modified by HHM, 21 july
    % generation of GRAD matrix
    thetaNew = max(lo, theta - ak.*ghat);
    thetaDelta = thetaNew - theta;
    GRAD(mod(k,horizon)+1,:) = thetaDelta;
    % generation of ERROR matrix
    ERROR(mod(k,horizon)+1,:) = (runSim(thetaNew,sensor_counts,wmatrix,secondorder_all) - runSim(theta,sensor_counts,wmatrix,secondorder_all))';
    ERROR(mod(k,horizon)+1,:) = -(1-beta) * ERROR(mod(k,horizon)+1,:);
    theta = thetaNew;
    % generation of DELTA_W matrix
    DELTA_W = estDeltaW(ERROR,GRAD,k+1);
    weight = beta * weight + DELTA_W;
    %weight = weight;
    
    path_y = FUNC(theta, sensor_counts, true, wmatrix,secondorder_all);    
    path_x = RMSN(x_true,theta);
    xrmsn = [xrmsn; path_x];
    save ./Results/fn_x.dat xrmsn -ascii;

    fn_path = [fn_path; path_y];
    save ./Results/fn_path.dat fn_path -ascii;

    
  end % iterations (k = 0:n-1)

  % save current fn values (at theta)

  save ./Results/x_final.dat theta -ascii;

% Display results: Mean loss value and standard deviation

