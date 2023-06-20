laser = rossubscriber('/base_scan');

%Fahrbefehle in Form von Geschwindigkeiten
robotCmd = rospublisher('/cmd_vel', 'geometry_msgs/Twist');
%Abstand zur Reihenmitte
distance_row_center = rospublisher('/offset', 'std_msgs/Float64');

%Orientierung zur Reihenmitte
orientation_row_center = rospublisher('/alpha', 'std_msgs/Float64');

%true, wenn innerhalb der Reihe
pub_inside_row = rospublisher('/inside_row', 'std_msgs/Bool');


robotPos = rossubscriber('/odom');
velMsg = rosmessage(robotCmd);



robot_speed = 0.4;
robot_width = 0.3;

while true
    
    
    
    
    
    scandata = receive(laser,10);
    angles = linspace(scandata.AngleMin, scandata.AngleMax, numel(scandata.Ranges));
    xy = readCartesian(scandata);
    ranges = scandata.Ranges;
    ranges(720)
    
    
    
    vel_msg = rosmessage(robotCmd);
    vel_msg.Linear.X = robot_speed;
    send(robotCmd,vel_msg);
    
%     if ranges(1)<0.36 && ranges(720)<0.36
%         vel_msg.Linear.X = 0;
%         vel_msg.Angular.Z = 0;
%     elseif ranges(1)<0.36
%         vel_msg.Linear.X = 0.5;
%         vel_msg.Angular.Z = 0.6;
%     elseif ranges(720)<0.36
%         vel_msg.Linear.X = 0.5;
%         vel_msg.Angular.Z = -0.6;
%     else
%         vel_msg.Linear.X = 0.5;
%         vel_msg.Angular.Z = 0;
%     end
%     send(robotCmd,vel_msg);
    
    
    if ranges(1) < 0.35
        vel_msg = rosmessage(robotCmd);
%         vel_msg.Linear.X = 0;
%         send(robotCmd,vel_msg);
        vel_msg.Angular.Z = 0.7;
        send(robotCmd,vel_msg);

    elseif ranges(720) < 0.35
        vel_msg = rosmessage(robotCmd);
%         vel_msg.Linear.X = 0;
%         send(robotCmd,vel_msg);       
        vel_msg.Angular.Z = -0.7;
        send(robotCmd,vel_msg);   
    end
    
    range_right = ranges(50:350);
    range_left = ranges(350:680);
    
    if min(range_right) < 0.2
        vel_msg = rosmessage(robotCmd);
%         vel_msg.Linear.X = 0;
%         send(robotCmd,vel_msg);
        vel_msg.Angular.Z = 0.4;
        send(robotCmd,vel_msg);    
    end
    if min(range_left) < 0.2
        vel_msg = rosmessage(robotCmd);
%         vel_msg.Linear.X = 0;
%         send(robotCmd,vel_msg);
        vel_msg.Angular.Z = -0.4;
        send(robotCmd,vel_msg);   
    end
    
    
    if min(ranges)>10
        vel_msg = rosmessage(robotCmd);
        vel_msg.Linear.X = 0.5;
        
        send(robotCmd, vel_msg);
        
        receive(robotPos);
         
        
    end
        
    

    
%     obstacle_mask = (xy(:,1)>0) & (abs(xy(:,2))<robot_width);
%     relevant_obstacles = xy(obstacle_mask,:);
%     [min_range,min_idx] = min(scandata.Ranges(obstacle_mask));
%     nearest_obstacle = relevant_obstacles(min_idx,:);
%     if min_range < 0.5
%         vel_msg = rosmessage(robotCmd);
%         vel_msg.Linear.X = 0;
%         send(robotCmd,vel_msg);
%         break;
%     else
%         
%     end
end