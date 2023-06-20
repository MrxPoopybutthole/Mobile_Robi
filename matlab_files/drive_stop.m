% publisher: sends cmd_vel commands to robot
% subscriber: gets scan data and calculates minimum distance

sub_laser = rossubscriber('/base_scan')
cmd_vel_publisher = rospublisher('/cmd_vel', 'geometry_msgs/Twist')

robot_width = 0.4;
robot_speed = 1;

distance = 10;
% while distance > 0.5
%     scandata = receive(sub_laser,10)
%     xy = readCartesian(scandata);
%     size(xy(300:420, :))
%     dist_vec = scandata.Ranges(260:460);
%     [distance, idx] = min(dist_vec);
%     
%     plot(xy(260:460, :), '*');
%   
%     mini_angle = scandata.AngleMin + scandata.AngleIncrement * idx
% 
%     x_value = cos(mini_angle) * idx
%     y_value = sin(mini_angle) * idx
% 
%     plot(x_value, y_value, 'r*');
%     
%     msg = rosmessage(cmd_vel_publisher);
%     msg.Linear.X = 1;
%     cmd_vel_publisher.send(msg);
%     
%     pause(0.5)
% end

% alternative
while distance > 0.5
    scandata = receive(sub_laser,10)
    xy = readCartesian(scandata);
    size(xy(300:420, :))
    xy(350, :)
    dist_vec = scandata.Ranges(260:460);
    [distance, idx] = min(dist_vec);
    
    plot(xy(260:460, :), '*');
  
    mini_angle = scandata.AngleMin + scandata.AngleIncrement * idx

    x_value = cos(mini_angle) * idx
    y_value = sin(mini_angle) * idx
    
    plot(xy(300:420, :), 'r*');
    clf;
    
    msg = rosmessage(cmd_vel_publisher);
    msg.Linear.X = 1;
    cmd_vel_publisher.send(msg);
    
    pause(0.5)
end