
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


roi_view_x = 2.5;
roi_view_y = 0.8;
turn_counter = 1;
robot_speed = 1.0;
robot_width = 0.3;
values = 1:720;
xy_plot = [];
while true
    
    
    scandata = receive(laser,10);
    angles = linspace(scandata.AngleMin, scandata.AngleMax, numel(scandata.Ranges));
    
    
    ranges = scandata.Ranges;
    ranges(720);
    
    

%     values = -0.25:.005:max(mittel_linie(:,2));
%     figure(5);
%     histogram(mittel_linie(:,2), values);

    
    vel_msg = rosmessage(robotCmd);
    vel_msg.Linear.X = robot_speed;
    send(robotCmd,vel_msg);
    
   
    % check if the robot is at the end of the maze
    % make a turn if the robot is at the end
    if min(ranges)>2
        
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
        while (rostime('now') - sendTime < durationCurve - 0.15) % 0.15 offset damit er die Kurve nicht noch weiter ausfährt
            send(robotCmd, vel_msg);
        end
        turn_counter = turn_counter + 1;
        
        
    elseif min(ranges) < 2
        
        %publish that the Robot is inside the maze 
        insideRowMsg.Data = true;
        send(pub_inside_row, insideRowMsg);
        %pub_inside_row.publish(insideRowMsg);
        
        xy = readCartesian(scandata);
        
        for i = 1:length(xy)
            if xy(i,2) < 2 || xy(i,2) > -2
                xy_plot = [xy_plot;xy(i,1),xy(i,2)];
            end
        end
    
%         figure();
%         plot(xy_plot(:,1),xy_plot(:,2));
%         
        
        roi = (xy(:,1) > 0 & xy(:,1) < roi_view_x) & (abs(xy(:,2)) < roi_view_y);
        found_points = xy(roi,:);
        
        points_left = [];
        points_right = [];
        mittel_linie = [];
        for i = 1:length(found_points)
            if found_points(i,2) > 0
                points_left = [points_left; found_points(i,1), (found_points(i,2) - 0.375)];
                mittel_linie = [mittel_linie; found_points(i,1), (found_points(i,2) - 0.375)];
            else

                points_right = [points_right; found_points(i,1), (found_points(i,2) + 0.375)];
                mittel_linie = [mittel_linie; found_points(i,1), (found_points(i,2) + 0.375)];
            end

        end
    
        if isempty(mittel_linie) == false
            avarg = mean(mittel_linie(:,2));            
        end
        
    
    
        if avarg < -0.055
            vel_msg = rosmessage(robotCmd);
            vel_msg.Angular.Z = -0.7;
            send(robotCmd,vel_msg);

        elseif avarg > 0.055
            vel_msg = rosmessage(robotCmd);      
            vel_msg.Angular.Z = 0.7;
            send(robotCmd,vel_msg);   
        end
    end
        

end