clear all;

%load generater;
%load wm;
load modified_wm;

global counter_glob;
counter_glob = 0;
global weight_percentage;
global config_for_five;

global window_for_five;


%load x_all;
x = x_all;
paramsPerDay = length(x);

%load y_all;
y = y_all;
sensor_counts = y;
no_sen = length(y);

%load wmatrix_all;
wmatrix = wmatrix_all;
%estimate_weightmatrix=ones(paramsPerDay,no_sen);

% modified by HHM, 21 july
p = paramsPerDay; % number of parameters to calibrate
m = no_sen; % number of measurements

%Algorithm parameters
n=300;		       %total no. of loss measurements
alpha =.602;
gamma =.101;
A=50;
a=2*10^(-5)*(A+1)^0.602;
c = 4;
grad_reps=1;
cut=25;
percentage = 0.3;
amplitude=[0.1,0.1];
pattern = 5;
threshold=0.001;
step=1;
after_cut_amplitude=1;
window_for_five=[1,10,10];%rmsn,g_record,theta
config_for_five=[1,0.1,0.1,0.1];%history, rmsn, g_record, theta stable

weight_percentage=ones(p,m) .* percentage;
%set the w-matrix
before_cut=ones(p,m);
%before_cut=estimate_weightmatrix;
after_cut=zeros(p,m);

%Start
theta_0_dynamit = x;
theta_0_spsa = ones(paramsPerDay,1);
%tmp_x = theta_0_spsa'; 
    



%save ./Results/fn_theta_0.dat tmp_fn -ascii;
    
%Initialize
x_values = [];
fn_values = [];
%fn_path = [];
%fn_path = [fn_path; initial_fn_value];
grad_log = [];
deltas = [];
nstart = 0;
rmsns=[];
thetas=[];
lossfinalsq=0;          %variable for cum.(over 'cases')squared loss values
lossfinal=0;            %variable for cum. loss values
g_record=[];

%Initial Objective Value
initial_fn_value = FUNC(theta_0_dynamit,sensor_counts, true, wmatrix,secondorder_all);
%xrmsn = RMSN(x_true,theta_0_dynamit);
%save ./Results/fn_x.dat xrmsn -ascii;
thetas=[thetas;theta_0_dynamit'];
rmsns=[rmsns;initial_fn_value'];
tmp_x = theta_0_spsa';
tmp_fn = initial_fn_value;

%Main Loop

theta = theta_0_dynamit;  % Start at seed parameter values

wmatrix_n = wmatrix_n_all;

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
    g = zeros(paramsPerDay,1);
   
    %tmp_fn_grad_reps = []; % Store the fn values for averaging

    for xx = 1:grad_reps 
      

      yplus=FUNC(thetaplus, sensor_counts, true, wmatrix,secondorder_all);
      yminus=FUNC(thetaminus, sensor_counts, true, wmatrix,secondorder_all);


      % Store the two fn values
      %tmp_fn = [yminus yplus];
      %tmp_fn_grad_reps = [tmp_fn_grad_reps; tmp_fn];

      thetadif = (thetaplus - thetaminus);%.*theta_0_dynamit;
      ydiff = yplus - yminus;

      %implement the w-spsa
      %only change
      %parfor ii = 1:paramsPerDay
      %    thisdiff =sum(ydiff);
      %    g(ii,1) = g(ii,1) + thisdiff/thetadif(ii,1);
      %end
      g_record=[g_record;ydiff'];
      if k<=cut
      parfor ii = 1:paramsPerDay       
          thisdiff = before_cut(ii, :) * ydiff;
          ghat(ii,1) = ghat(ii,1) + thisdiff/thetadif(ii,1);
      end
      else       
          after_cut=cut_after_gen(p, m, step) .* after_cut_amplitude;
          pertagetest(wmatrix_all,after_cut)
          parfor ii = 1:paramsPerDay        
          thisdiff = after_cut(ii, :) * ydiff;
          ghat(ii,1) = ghat(ii,1) + thisdiff/thetadif(ii,1);
          end
      end
      
    end % end of reps for grad averaging
    
    ghat = ghat/grad_reps;
    %ak = av/(k+1+A)^alpha;
    ak= a/(k+1+A)^alpha;
    theta=theta - ak.*ghat;
    theta = max(lo, theta);

    path_y = FUNC(theta, sensor_counts, true, wmatrix,secondorder_all);

    
    if k>cut
        flag=ml_change_percentage(after_cut, rmsns, thetas, g_record, amplitude, pattern, threshold, estimate_weightmatrix);
    end
    rmsns=[rmsns;path_y'];
    thetas=[thetas;theta'];

end