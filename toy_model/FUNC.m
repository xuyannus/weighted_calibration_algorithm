%y1=2*x1+3*x2^2-5*x3
%y2=3*x1+x2-5*x3^2

%X , Y is true sensor counts, 
function y = FUNC(X, Y, z, wmatrix,secondorder_all)


num = length(Y);


global counter_glob;
global iter;

if z == true
  counter_glob = counter_glob + 1;
end

bigsum = 0;   

sensor_counts = Y;
sim_counts=zeros(num,1);
for i=1:num
    %linear
    %sim_counts(i) = wmatrix(:, i)' * X;
    %nonlinear
    X_new=zeros(length(X),1);
    X_new=X.^2;
    sim_counts(i,1) = wmatrix(:, i)' * X+secondorder_all(:,i)'*X_new;
    %error in measure
    %noise = (2 * rand(1,1) - 1) * 0.01 + 1;
    %sim_counts(i, 1) = sim_counts(i, 1) * noise;
end

    dev = sensor_counts - sim_counts;
    
    diff_counts = dev'*dev;
    
    RMSN_counts = RMSN(sensor_counts,sim_counts) ;

  % Add to total
    bigsum = bigsum + diff_counts;
    

cd Results

if(counter_glob == 1)
    fn_Counts = [];
    fn_Counts = [1 diff_counts];
    fn_RMSE = [];
    fn_RMSN = [];
    fn_RMSN = [1 RMSN_counts];
     
    %save
    %save fn_Counts.dat fn_Counts -ascii;
    save fn_RMSN.dat fn_RMSN -ascii;
    %str=['save fn_RMSN' num2str(iter) '.dat fn_RMSN -ascii']
    %eval(str);
    
    %record every 3 iteration
else if( mod(counter_glob, 3) == 1 && counter_glob ~=1 )
    %load fn_Counts.dat;
    %fn_Counts = [fn_Counts ;counter_glob diff_counts];
    %save fn_Counts.dat fn_Counts -ascii;
    
    load fn_RMSN.dat;
    %str=['load fn_RMSN' num2str(iter) '.dat;'];
    %eval(str);
    fn_RMSN = [fn_RMSN; counter_glob RMSN_counts];
    %str = ['fn_RMSN' num2str(iter) '= [fn_RMSN' num2str(iter) '; counter_glob RMSN_counts];'];
    %eval(str);
    save fn_RMSN.dat fn_RMSN -ascii;
    %str=['save fn_RMSN' num2str(iter) '.dat fn_RMSN -ascii;'];
    %eval(str);
    
    end
end

cd ..

y = dev .^2; % Return total objective function for day
