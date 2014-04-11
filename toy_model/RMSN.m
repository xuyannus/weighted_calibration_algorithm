function r = RMSN(y_true, y_hat)

y_true = y_true(:);
n = length(y_true);
y_diff = y_true-y_hat(:);
r = sqrt(y_diff'*y_diff*n) / sum(y_true);

