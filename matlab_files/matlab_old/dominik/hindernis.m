laser = rossubscriber('/base_scan');
robotCmd = rospublisher('/cmd_vel', 'geometry_msgs/Twist');
velMsg = rosmessage(robotCmd);

scandata = receive(laser,10);
%plot(scandata)

velocity = 0.5;
m = 0;
while m == 0
    
    
    scandata = receive(laser,10);
    ranges = scandata.Ranges;

    angle_min = scandata.AngleMin;
    angle_inc = scandata.AngleIncrement;

    [min_range, min_index] = min(ranges);
    [max_range, max_index] = max(ranges);
    
    for i = 0:max_index
       
        angle_min_range = angle_min + (min_index-1+i) * angle_inc;
        angel_min_degree = angle_min_range * (180/pi);
        
        %only get range for angles that are between 60 and 120 degree
        if (80 <= angel_min_degree) && (angel_min_degree <= 100)
            
            [min_range, min_index] = min(ranges)
            
            if min_range < 0.5
                %stop robot
                velMsg.Linear.X = 0;
                send(robotCmd, velMsg);
                m = m + 1;
            end
        end
        i = i + 1;
        
    end
    
    %send command that the robot drives
    velMsg.Linear.X = velocity;
    send(robotCmd, velMsg);
    
     
    
    
end
            
        
        
            
    