laser = rossubscriber('/base_scan')
scandata = receive(laser,10)
plot(scandata)

ranges = scandata.Ranges
[min_range, min_index] = min(ranges)

angle_min = scandata.AngleMin
angle_max = scandata.AngleMax
angle_inc = scandata.AngleIncrement

% Get angle of the nearest point
angle_min_range = angle_min + (min_index-1) * angle_inc

% Convert polar coordinates to Cartesian coordinates
x = min_range * cos(angle_min_range);
y = min_range * sin(angle_min_range);


roboter_x = 1
roboter_y = 3

laser_offset_x = 0.32
laser_offset_y = -0.0185

laser_pos_x = roboter_x + laser_offset_x
laser_pos_y = roboter_y + laser_offset_y

world_coordiante_x = laser_pos_x + x
world_coordiante_y = laser_pos_y + y


print = sprintf('Closest point at %d, %d',x,y);
disp(print)
plot(scandata)



