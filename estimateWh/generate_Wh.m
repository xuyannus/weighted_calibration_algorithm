%This code follows estimateWh.m, it is the last porcess to estimate Wh, I write it seperately because you can use plenty of computer run DynaMIT and combine the data together,this code will finally give the W matrix
%By Ma Wei,15,08,2013

configure;

%you can change it
iteration = 5
threshold = 0.3

%establish a large matrix
cd iteration_record
load iteration1/thetadiff.dat;
load iteration1/ydiff.dat;
p=length(thetadiff);
m=length(ydiff);
estimate_weightmatrix=zeros(p,m);


%start the loop to estimate
for k= 1: iteration
  str=['load iteration' int2str(k) '/thetadiff.dat;'];
  eval(str);
  str=['load iteration' int2str(k) '/ydiff.dat;'];
  eval(str);
  for j = 1:length(ydiff)
    estimate_weightmatrix(:,j) = ((k-1)/k) .* estimate_weightmatrix(:,j) + (1/k) .* (ydiff(j) ./ thetadiff);
  end
end
cd ..

%normalize
for i=1:p
  estimate_weightmatrix(i,:)=abs(estimate_weightmatrix(i,:));
  maxe=max(estimate_weightmatrix(i,:));
  maxe=max(0.001,maxe);
  estimate_weightmatrix(i,:)=estimate_weightmatrix(i,:)./maxe;
end

%give threshold
for j=1:m
  for i=1:p
    if estimate_weightmatrix(i,j)<threshold
      estimate_weightmatrix(i,j)=0;
    else
      estimate_weightmatrix(i,j)=1;
    end
  end
end

disp('Simplification finish!');
%now we can do the interval elimination, using the prior information of interval effect.
disp('Start using interval information.');

interval_effect
no_sensors

estimate_weightmatrix = interval_Effect(estimate_weightmatrix, interval_effect, no_sensors);  

%last step, save it
save2SparseMatrix(estimate_weightmatrix);

disp("All Finish!")
