%This code will receive the number of iterations it need to perturb and do the perturbation
%By Mawei 22.08.2013

function copy_prototype(num, start, duration)
  str=['cp -r prototype DynaMIT' int2str(num)];
  system(str);

  estimateWh(num, start, duration);
