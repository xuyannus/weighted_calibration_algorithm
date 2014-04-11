function M = runSim(X,Y,wmatrix,secondorder_all)
% return the simulation counts of the measurements, a m by 1 column vector
num = length(Y);
sensor_counts = Y;

for i=1:num
    X_new=zeros(length(X),1);
    X_new=X.^2;
    sim_counts(i,1) = wmatrix(:, i)' * X+secondorder_all(:,i)'*X_new;
end

M = sim_counts - sensor_counts;
end

