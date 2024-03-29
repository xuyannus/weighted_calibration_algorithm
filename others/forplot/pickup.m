function rmsn = pickup(sensor,interval) 
% if sensor == 0, pick up all sensors in a given interval
% if interval == 0, pick up a given sensor in all intervals
configure;
cd parameter_record;
str = ['cd global' int2str(1) ';'];
eval(str);
load sim_counts.dat
load dev.dat
sensor_counts = sim_counts + dev;
cd ..
cd ..

picked_sensor_count = [];
picked_sim_count = [];
no_sensors = 58;
no_intervals = end_int - start_int - warm_up;

if sensor == 0
  if interval == 0
    picked_sensor_count = [];
    picked_sim_count = [];
  else
    picked_sensor_count = sensor_counts((interval - 1) * no_sensors + 1:interval * no_sensors, 1);
    picked_sim_count = sim_counts((interval - 1) * no_sensors + 1:interval * no_sensors, 1);
  end
else
  if interval == 0
    for i = 1:no_intervals
      picked_sensor_count = [picked_sensor_count; sensor_counts((i - 1) * no_sensors + sensor, 1)];
      picked_sim_count = [picked_sim_count; sim_counts((i - 1) * no_sensors + sensor, 1)];
    end
  else
    picked_sensor_count = sensor_counts((interval - 1) * no_sensors + sensor, 1);
    picked_sim_count = sim_counts((interval - 1) * no_sensors + sensor, 1);
  end
end

if sensor ~= 0
 
  figure
  plot(picked_sensor_count,'r',picked_sim_count,'g');
  legend('real','simulate')
  xlabel('NO-interval')
  ylabel('Counts')
  title('Comprizon')
else
  figure;
  for i = 1:length(picked_sensor_count)
    plot(picked_sensor_count(i),picked_sim_count(i),'b+');
    hold on;
  end
  plot([0,2000],[0,2000],'r');
  xlabel('Observed Counts')
  ylabel('Simulated Counts')
  title('Comprizon')
end


rmsn = RMSN(picked_sensor_count,picked_sim_count);

end


