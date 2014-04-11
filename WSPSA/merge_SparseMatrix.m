%by hhm,16aug
function WM = merge_WM(wh,wc)
wh_Index = 1;
wc_Index = 1;
wh_MaxIndex = size(wh,1);
wc_MaxIndex = size(wc,1);
WM = [];
while (wh_Index <= wh_MaxIndex && wc_Index <= wc_MaxIndex)
  if wh(wh_Index,1) < wc(wc_Index,1) % row number of wh is smaller
    WM = [WM;wh(wh_Index,:)];
    wh_Index = wh_Index + 1;
  else
    if wh(wh_Index,1) > wc(wc_Index,1) % row number of wh is larger
      WM = [WM;wc(wc_Index,:)];
      wc_Index = wc_Index + 1;
    else % equal
      if wh(wh_Index,2) < wc(wc_Index,2) % column number of wh is smaller
        WM = [WM;wh(wh_Index,:)];
        wh_Index = wh_Index + 1;
      else
        if wh(wh_Index,2) > wc(wc_Index,2) % column nubmer of wh is larger
          WM = [WM;wc(wc_Index,:)];
          wc_Index = wc_Index + 1;
        else % equal
          wm_line = wh(wh_Index,:);
          wm_line(1,3) = wm_line(1,3) + wc(wc_Index,3);
          WM = [WM;wm_line];
          wh_Index = wh_Index + 1;
          wc_Index = wc_Index + 1;
        end
      end
    end
  end
end

if wh_Index > wh_MaxIndex
  while wc_Index <= wc_MaxIndex
    WM = [WM;wc(wc_Index,:)];
    wc_Index = wc_Index + 1;
  end
else
  while wh_Index <= wh_MaxIndex
    WM = [WM;wh(wh_Index,:)];
    wh_Index = wh_Index + 1;
  end
end



end
