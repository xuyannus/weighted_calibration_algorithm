%
clear;
clc;

 %CoreNum=4;
 %if matlabpool('size')<=0 
 %matlabpool('open','local',CoreNum);
 %else
 %disp('Already initialized');
 %end
 
%Generate x_true
interval = 8;
n_x = 1000;
x_mean = 20;
x_true = rand(n_x*interval,1) * x_mean * 2;
%save x_true;

%number of ys
n_y = 200;

%Generate correlation matrix
wmatrix = rand(n_x, n_y);

%if there is threshold
for i=1:n_x
    threshold = 0.80; %1 x is related to 10 ys
    for j = 1:n_y
        if wmatrix(i, j) < threshold
            wmatrix(i, j) = 0;
        else
            wmatrix(i, j) = 1;
        end
    end
end
weight = rand(n_x, n_y);
wmatrix = wmatrix .* weight;

%Generate noise
% w_noise = ones(n_x, n_y) * 10;
% wmatrix_n = wmatrix .* w_noise;
% ub = ones(n_x, n_y);
% wmatrix_n = min(wmatrix_n,ub);
% row = size(wmatrix,1);
% col = size(wmatrix,2);
% parfor i=1:row
%     for j=1:col
%         if wmatrix_n(i,j) == 0
%             if rand(1,1) < 0.3
%                 wmatrix_n(i,j) = 1
%             end
%         end
%     end
% end

%if no noise
%wmatrix_noise
wmatrix_n = wmatrix;

%he think two different interval do not influence each other
%so only when i=j, the weight matrix exit
%and just copy the weight matrix
%means the road condition the same
wmatrix_all = [];
wmatrix_n_all = [];
for i=1:interval
    cur = [];
    cur_n = [];
    for j=1:interval
        if j == i
            cur_n = [cur_n, wmatrix_n];
            cur=[cur,wmatrix];
        else
            cur = [cur,zeros(n_x,n_y)];
            cur_n = [cur_n, zeros(n_x,n_y)];
        end
    end
    wmatrix_all = [wmatrix_all;cur];
    wmatrix_n_all = [wmatrix_n_all;cur];
end

    
%save wmatrix_all

%%Generate y_true
%wmatrix also mean linear function
% x means parameters
for k = 1:interval
    for i = 1:n_y
        index = (k-1)*n_y+i;
        y_true_all(index,1) = 0;
        for j=1:n_x*interval
            y_true_all(index,1) = y_true_all(index,1) + x_true(j,1) * wmatrix_all(j, index);
        end
    end
end
% y_true_all = [];
% for i =1:interval
%     y_true_all = [y_true_all;y_true];
% end
%save y_true_all;

%Generate initial x
%x=[];
%for i=1:interval
    %x=[x;x_true];
%end

%initial theta
x = ones(n_x,1);
parfor i=1:n_x
    if x_true(i,1) <= 15
        x(i,1) = 7.5;
    else
        x(i,1) = 22.5;
    end
end
x_all = [];
for i=1:interval
    x_all = [x_all;x];
end
%x = ones(n_x*interval,1) * 10;
%save x_all;

%Generate noise in y
scale = 0.00;
noise = (2 * rand(n_y*interval, 1) - 1) * 2 * scale;
parfor i=1:n_y*interval
    if abs(noise(i,1)) < 0
        noise(i, 1) = 0;
    end
end
noise = noise + 1;
y_all = y_true_all .* noise;
% y_all = [];
% for i=1:interval
%     y_all = [y_all;y];
% end
%save y_all;
secondorder_all=zeros(n_x*interval,n_y*interval);
%save y_all, x_all(initial), x_true, wmatrix(include the funcion and weight Matrix)
save generater;

rmsn = RMSN(y_true_all, y_all) %inspect how much noise we give to y