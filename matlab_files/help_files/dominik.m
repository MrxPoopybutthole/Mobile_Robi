
laser = rossubscriber('/base_scan');
robotPos = rossubscriber('/odom');

%Fahrbefehle in Form von Geschwindigkeiten
robotCmd = rospublisher('/cmd_vel', 'geometry_msgs/Twist');
velMsg = rosmessage(robotCmd);

%Abstand zur Reihenmitte
distance_row_center = rospublisher('/offset', 'std_msgs/Float64');
distanceMsg = rosmessage(distance_row_center);

%Orientierung zur Reihenmitte
orientation_row_center = rospublisher('/alpha', 'std_msgs/Float64');
orientationMsg = rosmessage(orientation_row_center);

%true, wenn innerhalb der Reihe
pub_inside_row = rospublisher('/inside_row', 'std_msgs/Bool');
insideRowMsg = rosmessage(pub_inside_row);



turn_counter = 1;
robot_speed = 0.4;
robot_width = 0.3;
values = 1:720;

while true
    
    
    scandata = receive(laser,10);
    angles = linspace(scandata.AngleMin, scandata.AngleMax, numel(scandata.Ranges));
    xy = readCartesian(scandata);
    plot(xy(:,1),xy(:,2));
    
    ranges = scandata.Ranges;
    ranges(720);
    
    

    
    vel_msg = rosmessage(robotCmd);
    vel_msg.Linear.X = robot_speed;
    send(robotCmd,vel_msg);
    
    bar(values,ranges);
    
       
    
    
    if ranges(1) < 0.35
        vel_msg = rosmessage(robotCmd);
        vel_msg.Angular.Z = 0.7;
        send(robotCmd,vel_msg);

    elseif ranges(720) < 0.35
        vel_msg = rosmessage(robotCmd);      
        vel_msg.Angular.Z = -0.7;
        send(robotCmd,vel_msg);   
    end
    
    range_right = ranges(50:350);
    range_left = ranges(350:680);
    
    if min(range_right) < 0.2
        vel_msg = rosmessage(robotCmd);
        vel_msg.Angular.Z = 0.4;
        send(robotCmd,vel_msg);    
    end
    if min(range_left) < 0.2
        vel_msg = rosmessage(robotCmd);
        vel_msg.Angular.Z = -0.4;
        send(robotCmd,vel_msg);   
    end
    
    
    % check if the robot is at the end of the maze
    % make a turn if the robot is at the end
    if min(ranges)>3
        
        %publish that the Robot is not inside the maze 
        insideRowMsg.Data = false;
        send(pub_inside_row, insideRowMsg);
        %pub_inside_row.publish(insideRowMsg);
        
        distance = 0.5;
        
        if mod(turn_counter, 2) == 0
            direction = -1;
        else
            direction = 1;
        end 
        
        velocity = 0.5;
        radius = 0.4;
        linearSpeed = velocity;
        angularSpeed = velocity/radius;
        durationStraight = distance/ linearSpeed;
        
        % drive a little bit out of the maze field in a straight line
        vel_msg.Angular.Z = 0;
        sendTime = rostime('now');
        while (rostime('now') - sendTime < durationStraight)
            send(robotCmd, vel_msg);
        end 
        
        % make a turn
        angle = pi;
        durationCurve = angle/angularSpeed;
        vel_msg.Linear.X = linearSpeed;
        vel_msg.Angular.Z = direction * angularSpeed;
        sendTime = rostime('now');
        while (rostime('now') - sendTime < durationCurve)
            send(robotCmd, vel_msg);
        end
        turn_counter = turn_counter + 1;
        
        
    else
        %publish that the Robot is inside the maze 
        insideRowMsg.Data = true;
        send(pub_inside_row, insideRowMsg);
        %pub_inside_row.publish(insideRowMsg);
    end
        

end

