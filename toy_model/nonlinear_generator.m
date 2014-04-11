clear;
clc;

%Generate x_true
interval = 2;
n_x = 1000;
x_mean = 20;
x_true = rand(n_x*interval,1) * x_mean * 2;

%number of ys
n_y = 200;

%Generate correlation matrix
correlation = rand(n_x, n_y);

%if there is threshold
for i=1:n_x
    threshold = 0.8; %1 x is related to 10 ys
    for j = 1:n_y
        if correlation(i, j) < threshold
            correlation(i, j) = 0;
        else
            correlation(i, j) = 1;
        end
    end
end
weight = rand(n_x, n_y);
wmatrix = correlation .* weight;%if no noise
%wmatrix_noise
wmatrix_n = wmatrix;


%generate 2nd-order

%parameters
secondorder_correlation=rand(n_x,n_y);
%if there is threshold
for i=1:n_x
    threshold =0.8; %1 x is related to 10 ys
    for j = 1:n_y
        if secondorder_correlation(i, j) < threshold
            secondorder_correlation(i, j) = 0;
        else
            secondorder_correlation(i, j) = 1;
        end
    end
end
secondorder=rand(n_x,n_y);
secondorder=secondorder.*correlation;


%generate wmatrix all
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

%generate secondorder_all
secondorder_all = [];
for i=1:interval
    cur = [];
    cur_n = [];
    for j=1:interval
        if j == i
            cur=[cur,secondorder];
        else
            cur = [cur,zeros(n_x,n_y)];
        end
    end
    secondorder_all = [secondorder_all;cur];
end

%%Generate y_true
%wmatrix also mean linear function
% x means parameters
for k = 1:interval
    for i = 1:n_y
        index = (k-1)*n_y+i;
        y_true_all(index,1) = 0;
        for j=1:n_x*interval
            y_true_all(index,1) = y_true_all(index,1) + wmatrix_all(j, index)*( x_true(j,1))+ secondorder_all(j, index)*(x_true(j,1)^2);
        end
    end
end

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

save generater;

rmsn = RMSN(y_true_all, y_all) %inspect how much noise we give to y
