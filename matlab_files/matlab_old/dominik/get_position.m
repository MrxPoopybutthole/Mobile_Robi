laser = rossubscriber('/base_scan');
robotCmd = rospublisher('/cmd_vel', 'geometry_msgs/Twist');
velMsg = rosmessage(robotCmd);
scandata = receive(laser,10);


robotPos = rossubscriber('/odom');

angle_min = scandata.AngleMin
angle_max = scandata.AngleMax
angle_inc = scandata.AngleIncrement

% Get angle of the nearest point
%angle_min_range = angle_min + (min_index-1) * angle_inc

% Convert polar coordinates to Cartesian coordinates
%x = min_range * cos(angle_min_range);
%y = min_range * sin(angle_min_range);

alpha = 0;


velMsg.Angular.Z = -pi/2;
send(robotCmd, velMsg);
%pause(0.1);
receive(robotPos);

scandata = receive(laser,10);
ranges = scandata.Ranges;
[min_range, min_index] = min(ranges);

angle_min = scandata.AngleMin;
angle_max = scandata.AngleMax;
angle_inc = scandata.AngleIncrement;

% Get angle of the nearest point
angle_min_range = angle_min + (min_index-1) * angle_inc;

% Convert polar coordinates to Cartesian coordinates
x = min_range * cos(angle_min_range)
y = min_range * sin(angle_min_range)
alpha = alphahist([x,y], alpha)
        



