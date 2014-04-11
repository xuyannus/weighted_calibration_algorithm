%There are many starting script

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
FIRST

generator2.m
nonlinear_generator.m

these two will generate the weight matrix(linear and non-linear)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SECOND

w_estimate.m      get the Wh

modify_wm.m       give threshold

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
THIRD

there are a lot of entry

1.wspsa_non1.m       By LULU,original W-spsa
2.spsa_non.m         By LULU,original SPSA
3.wspsa_non.m        By haomin, horizon idea
4.wspsa_non_estimatematrix   By mawei,only Wh
5.go_horizon.m       By mawei,Wh+Wc or ones+Wc
6.ml_algo.m          By mawei, lot of trials, different pattern


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
OTHER
pertagetest.m      a tool to test the effiency.