%by hhm,16aug
function wc = generate_Wc(oldWC, oldWH, rmsns, thetas, g_record, amplitude)     

global weight_percentage;
global window;
[loop,m] = size(rmsns);
[loop,p] = size(thetas);
TempG = g_record((loop-window + 1):loop,:);
TempT = thetas((loop-window + 1):loop,:);
TempRelative = window_Estimate(TempT,TempG,1);
current_weight = zeros(p,m) - amplitude(2);

WM = merge_SparseMatrix(oldWC,oldWH);
wm_Index = 1;
wm_MaxIndex = size(WM,1);

tic;
i = 1;
while wm_Index <= wm_MaxIndex
  while (i ~= WM(wm_Index,1))
    for j = 1:m
      if TempRelative(i,j) > 0
        current_weight(i,j) = amplitude(1) / 2;
      end
    end
    %current_weight(i,:) = sign(TempRelative(i,:)) .* (amplitude(1) / 2);
    i = i + 1;
  end

  while(wm_Index <= wm_MaxIndex && WM(wm_Index,1) == i)
    j = WM(wm_Index,2);
    current_weight(i,j) = amplitude(1);
    wm_Index = wm_Index + 1;
  end
end
t1 = toc


tic;
weight_percentage = current_weight + weight_percentage;
wc = [];
rand_matrix = rand(p,m);
t2 = toc

tic;

for i = 1:p
  for j = 1:m
    if rand_matrix(i,j) < weight_percentage(i,j)
      wc = [wc; i j 1];
    end
  end
end
t3 = toc

%save wc.dat wc -ascii;

end
