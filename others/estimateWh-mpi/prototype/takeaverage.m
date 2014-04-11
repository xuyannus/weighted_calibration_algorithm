function mean_value = takeaverage(spd_v)
  spd_s = sum(spd_v);
  cou = sum(spd_v != 0);
  for i = 1:length(cou)
    if cou(i) == 0
      cou(i)=1;
    end
  end
  mean_value = spd_s ./ cou;
end
