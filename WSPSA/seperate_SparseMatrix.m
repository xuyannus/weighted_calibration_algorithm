%by hhm,16aug
function [od_WM,cap_WM,spddsy_WM,rt_WM] = seperate_WM(WM,num_od,num_cap,num_spddsy,num_rt)
max_WMIndex = size(WM,1);
od_WM = [];
cap_WM = [];
spddsy_WM = [];
rt_WM = [];
for cur_WMIndex = 1:1:max_WMIndex
  if WM(cur_WMIndex,1) <= num_od
    od_WM = [od_WM;WM(cur_WMIndex,:)];
  else
    if WM(cur_WMIndex,1) <= num_od + num_cap
      cap_WM = [cap_WM;WM(cur_WMIndex,:)];
    else
      if WM(cur_WMIndex,1) <= num_od + num_cap + num_spddsy
        spddsy_WM = [spddsy_WM;WM(cur_WMIndex,:)];
      else
        rt_WM = [rt_WM;WM(cur_WMIndex,:)];
      end
    end
  end
end
end
