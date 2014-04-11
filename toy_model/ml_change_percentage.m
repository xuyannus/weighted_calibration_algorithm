function flag=ml_change_percentage (after_cut, rmsns, thetas, g_record, amplitude, pattern, threshold, estimate_weightmatrix)

global weight_percentage;
global config_for_five;%history, rmsn, g_record, theta stable
global window_for_five;
[loop,m] = size(rmsns);
[loop,p] = size(thetas);
alpha=0.05;

%pattern one, just use the macro information
 if pattern==1
     if sum(rmsns(loop,:)) < sum(rmsns(loop-1,:)) - threshold * sum(rmsns(loop-1,:))
         for i=1:1:p
             for j=1:1:m
                 if after_cut(i,j)>0
                     weight_percentage(i,j)=weight_percentage(i,j)+amplitude(1);
                 end
             end
         end 
     end
     if sum(rmsns(loop,:)) < sum(rmsns(loop-1,:))
         for i=1:1:p
             for j=1:1:m
                 if after_cut(i,j)>0
                     weight_percentage(i,j)=weight_percentage(i,j)-amplitude(2);
                 end
             end
         end 
     end

 end
 
 % try to use some detail
 if pattern==2
     for j=1:1:m
         if rmsns(loop,j) < rmsns(loop-1,j)
             for i=1:1:p
                 if after_cut(i,j)>0
                    weight_percentage(i,j)=weight_percentage(i,j) + amplitude(1);
                 end
             end
         end
         
         if rmsns(loop,j) > rmsns(loop-1,j)
             for i=1:1:p
                 if after_cut(i,j)>0
                    weight_percentage(i,j)=weight_percentage(i,j) - amplitude(2);
                 end
             end
         end         
     end
 end
 
 
 if pattern==3
     for i=1:1:p
         if (thetas(loop,i)-thetas(loop-1,i))*(thetas(loop-1,i)-thetas(loop-2,i))>0
             for j=1:1:m
                 if after_cut(i,j)>0
                    weight_percentage(i,j)=weight_percentage(i,j) + amplitude(1);
                 end
             end
         end
         if (thetas(loop,i)-thetas(loop-1,i))*(thetas(loop-1,i)-thetas(loop-2,i))<0
             for j=1:1:m
                 if after_cut(i,j)>0
                    weight_percentage(i,j)=weight_percentage(i,j) - amplitude(2);
                 end
             end
         end
     end
 end
 
 if pattern==4
     for j=1:1:m
         if rmsns(loop,j) < rmsns(loop-1,j) 
             for i=1:1:p
                 if after_cut(i,j)>0 && estimate_weightmatrix(i,j)>0
                    weight_percentage(i,j)=weight_percentage(i,j) + amplitude(1);
                 else if after_cut(i,j)>0
                    weight_percentage(i,j)=weight_percentage(i,j) + amplitude(1) /2;
                     end
                 end
             end
         end
         
         if rmsns(loop,j) > rmsns(loop-1,j)
             for i=1:1:p
                 if after_cut(i,j)>0
                    weight_percentage(i,j)=weight_percentage(i,j) - amplitude(2);
                 end
             end
         end         
     end
 end
 
 %combination

 if pattern==5
     TempG=g_record((loop-window_for_five(2)+1):loop,:);
     TempT=thetas((loop-window_for_five(2)+1):loop,:);
     TempRelative=horizon_estimate(TempT,TempG,1);  
     current_weight=zeros(p,m);
     for j=1:m
         for i=1:p
             if after_cut(i,j)>0 && estimate_weightmatrix(i,j)>0
                 %history
                 mass=zeros(4,3);
                 if estimate_weightmatrix(i,j)>0
                     mass(1,1)=config_for_five(1);
                     mass(1,2)=1-config_for_five(1);
                 else 
                     mass(1,2)=1-config_for_five(1);
                     mass(1,3)=config_for_five(1);
                 end
                 %rmsn
                 if rmsns(loop,j) < rmsns(loop-1,j)
                     mass(2,1)=config_for_five(2);
                     mass(2,2)=1 - config_for_five(2);
                 else
                     mass(2,3)=config_for_five(2);
                     mass(2,2)=1 - config_for_five(2);     
                 end
                 %g_record
                 if TempRelative(i,j) > 0
                    mass(3,1)=config_for_five(3);
                    mass(3,2)=1 - config_for_five(3);
                 else
                    mass(3,3)=config_for_five(3);
                    mass(3,2)=1 - config_for_five(3);  
                 end
                 %theta
                 TempTh=thetas((loop-window_for_five(3)+1):loop,:);
                 indicator=lillietest(TempTh(:,j),alpha);
                 %indicator=ttest(TempTh(:,j),alpha);
                 %indicator=1;
                 if indicator == 0
                     mass(4,1)= (1-alpha) * config_for_five(4);
                     mass(4,2)= 1 - config_for_five(4);
                     mass(4,3)= alpha * config_for_five(4);
                 else
                     mass(4,3)= (1-alpha) * config_for_five(4);
                     mass(4,2)= 1 - config_for_five(4);                        
                     mass(4,1)= alpha * config_for_five(4);
                 end
                 %combination
                 tempEvidence=multids(mass);
                 if tempEvidence(1) > tempEvidence(2)
                     current_weight(i,j) = current_weight(i,j) + amplitude(1);
                 else
                     if tempEvidence(1) < tempEvidence(2)
                     current_weight(i,j) = current_weight(i,j) - amplitude(2);
                     end
                 end                 
             end
         end
     end
     weight_percentage = current_weight + weight_percentage;
 end
 
  if pattern==6
     TempG=g_record((loop-window_for_five(2)+1):loop,:);
     TempT=thetas((loop-window_for_five(2)+1):loop,:);
     TempRelative=horizon_estimate(TempT,TempG,1);
     current_weight=zeros(p,m);
     for i=1:p
         for j=1:m
             if after_cut(i,j)>0 && TempRelative(i,j)>0
                 if estimate_weightmatrix(i,j) > 0
                     current_weight(i,j) = current_weight(i,j) + amplitude(1);
                 else
                     current_weight(i,j) = current_weight(i,j) + amplitude(1) / 2;
                 end
             else
                 if estimate_weightmatrix(i,j) > 0
                     current_weight(i,j) = current_weight(i,j) + amplitude(1) ;
                 else
                     current_weight(i,j) = current_weight(i,j) - amplitude(2) ;
                 end
             end            
         end
     end
     weight_percentage = current_weight + weight_percentage;
  end
             

         %modify
    for i=1:1:p
        for j=1:1:m
            if weight_percentage(i,j)<=0.05
                weight_percentage(i,j)=0;
            end
            if weight_percentage(i,j)> 1
                weight_percentage(i,j)=1;
            end
        end
    end

    flag=1;
end

 