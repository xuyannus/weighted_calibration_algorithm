clear all;

load generater;
%load wm;
%load modified_wm;
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

% modified by HHM, 21 july
p = paramsPerDay; % number of parameters to calibrate
m = no_sen; % number of measurements

%Algorithm parameters
n=300;		       %total no. of loss measurements
alpha =.602;
gamma =.101;
A=50;
a=0.15*10^(-8)*(A+1)^0.602;
c = 4;
horizon = 50; % horizon size
amp = 1;
%ratio =0.2;
%Start
theta_0_dynamit = x;
theta_0_spsa = ones(paramsPerDay,1);
tmp_x = theta_0_spsa'; 
    
%Initial Objective Value
initial_fn_value = FUNC(theta_0_dynamit,sensor_counts, true, wmatrix,secondorder_all);
xrmsn = RMSN(x_true,theta_0_dynamit);
%save ./Results/fn_x.dat xrmsn -ascii;

tmp_x = theta_0_spsa';
tmp_fn = initial_fn_value;
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
%by mawei,hu haomin, 2013/7/25
T_DIFF = zeros(horizon,p); % grad
Y_DIFF = zeros(horizon,m); % ...
%ew_Tmp = estimate_weightmatrix;
ew_Tmp = ones(p, m);
%ew_Tmp = zeros(p, m);
%ew_Tmp = wmatrix;
estimate_weightmatrix=ew_Tmp;
%ew_Tmp = rand(p, m);
old = zeros(p, m);
mag_scale = 1; % we scale delta by this percent of parameter magnitude
lossfinalsq=0;          %variable for cum.(over 'cases')squared loss values
lossfinal=0;            %variable for cum. loss values

%Main Loop

theta = theta_0_dynamit;  % Start at seed parameter values

wmatrix_n = wmatrix_n_all;

%generate a vector
init = initial_fn_value;
init_sum = zeros(paramsPerDay,1);
fn_value=initial_fn_value;

        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   old_estimate_weightmatrix=estimate_weightmatrix;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k= nstart:nstart+n-1
      if mod(k,10) == 0
          k
      end
    
      ck = c / (k+1)^gamma;
      delta1= 2 * round(rand(paramsPerDay,1))-1;
      delta2= unifrnd(0.9,1,paramsPerDay,1);
      delta=delta1.*delta2;
     % deltas = [deltas; (delta)'];

      %save ./Results/deltas.dat deltas -ascii;

      lo1 = zeros(paramsPerDay,1);
      lo1 = lo1 + 0.0001;
      lo2 = zeros(paramsPerDay,1);
      lo2 = lo2 + 0.0002;
      
      thetaplus = theta + ck.*delta;
      thetaminus = theta - ck.*delta;

      thetaplus = max(lo1, thetaplus);
      thetaminus = max(lo2, thetaminus);

       
        ghat = zeros(paramsPerDay,1);
   
        %tmp_fn_grad_reps = []; % Store the fn values for averaging

        for xx = 1:grad_reps 
      

        yplus=FUNC(thetaplus, sensor_counts, true, wmatrix,secondorder_all);
        yminus=FUNC(thetaminus, sensor_counts, true, wmatrix,secondorder_all);


        % Store the two fn values
        %tmp_fn = [yminus yplus];
        %tmp_fn_grad_reps = [tmp_fn_grad_reps; tmp_fn];

      thetadif = (thetaplus - thetaminus);%.*theta_0_dynamit;
      T_DIFF(mod(k,horizon)+1,:) = thetadif;
      %T_DIFF(mod(k,horizon)+1,:) = 2 * ck .* delta;
      ydiff = yplus - yminus;
      Y_DIFF(mod(k,horizon)+1,:)=ydiff;
      
      
        
      
      %implement the w-spsa
      %only change
      if k>horizon-1
      %go with calibration
      
        it_estimate_weightmatrix=horizon_estimate(T_DIFF, Y_DIFF,interval);   
        pertagetest(wmatrix_all,abs(it_estimate_weightmatrix));
        %it_estimate_weightmatrix=randommatrix(ratio, ew_Tmp);
      %it_estimate_weightmatrix=(k/(k+1)).*it_estimate_weightmatrix+(1/(k+1)).*old_estimate_weightmatrix;
      %old_estimate_weightmatrix=it_estimate_weightmatrix;
      else
          it_estimate_weightmatrix=zeros(p, m);
      end

      
        %normlize
        
       %plus_estimate_weightmatrix=it_estimate_weightmatrix;
      plus_estimate_weightmatrix=zeros(p, m);
    for i=1:1:paramsPerDay
        it_estimate_weightmatrix(i,:)=abs(it_estimate_weightmatrix(i,:));
        maxe=max(it_estimate_weightmatrix(i,:));
        maxe=max(0.001,maxe);
        plus_estimate_weightmatrix(i,:)=it_estimate_weightmatrix(i,:)./maxe;
        %plus_estimate_weightmatrix(i,:)=it_estimate_weightmatrix(i,:)./1e20;
    end
        %amp=sqrt(k);
        plus_estimate_weightmatrix = old + plus_estimate_weightmatrix;
        old=plus_estimate_weightmatrix;
        %estimate_weightmatrix = amp .*  plus_estimate_weightmatrix + ew_Tmp;
        estimate_weightmatrix = amp .*  plus_estimate_weightmatrix ;
        pertagetest(wmatrix_all,estimate_weightmatrix) ;
      if k>horizon-1
          
        parfor ii = 1:paramsPerDay          
          thisdiff = estimate_weightmatrix(ii, :) * ydiff;
          ghat(ii,1) = ghat(ii,1) + thisdiff/thetadif(ii,1);
        end
      else 
        parfor ii = 1:paramsPerDay          
          thisdiff = ew_Tmp(ii, :) * ydiff;
          ghat(ii,1) = ghat(ii,1) + thisdiff/thetadif(ii,1);
        end
      end

    end % end of reps for grad averaging

    %aa = mean(tmp_fn_grad_reps(:,1:1));
    %bb = mean(tmp_fn_grad_reps(:,2:2));

    %tmp_fn = [aa bb];
    %fn_values = [fn_values; tmp_fn];

    ghat = ghat/grad_reps;
	 
    %generate a vector
	init_sum = zeros(paramsPerDay,1);
	parfor ii = 1:paramsPerDay
        init_sum(ii,1) = estimate_weightmatrix(ii, :) * ((yplus+yminus)./2);
    end
	a_ratio = init_sum / sum((yplus+yminus)./2);
    av = a * ones(paramsPerDay,1)./ a_ratio;
    
    %ak = av/(k+1+A)^alpha;
    ak = a/(k+1+A)^alpha;
    theta=theta - ak.*ghat;
    theta = max(lo1, theta);

    path_y = FUNC(theta, sensor_counts, true, wmatrix,secondorder_all);
    
    %path_x = RMSN(x_true,theta);
    %xrmsn = [xrmsn; path_x];
    %save ./Results/fn_x.dat xrmsn -ascii;

    %fn_path = [fn_path; path_y];
    %save ./Results/fn_path.dat fn_path -ascii;

end % iterations (k = 0:n-1)

  % save current fn values (at theta)

  %save ./Results/x_final.dat theta -ascii;

% Display results: Mean loss value and standard deviation

