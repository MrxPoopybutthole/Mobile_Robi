clear all;
laser = rossubscriber('/base_scan');
robotCmd = rospublisher('/cmd_vel', 'geometry_msgs/Twist');
robotPos = rossubscriber('/odom');
velMsg = rosmessage(robotCmd);

for i= 0:10
    velMsg.Angular.Z = -pi/2;
    send(robotCmd, velMsg);
    receive(robotPos);
end
scandata = receive(laser,10);
ranges = scandata.Ranges;

winkel = histo(scandata, ranges);

%xy = readCartesian(scandata);
%histogram(xy);
plot(ranges);
xlabel('Gradzahlen');
ylabel('Abstand');

bar(winkel, ranges);

lokal_max = ranges(240:500)
[max_range, max_index] = max(lokal_max)
lokal_angle = winkel(max_index)

function [winkel] = histo(scandata, ranges)
    

    [min_range, min_index] = min(ranges);
    [max_range, max_index] = max(ranges);

    angle_min = scandata.AngleMin;
    angle_max = scandata.AngleMax;
    angle_inc = scandata.AngleIncrement;
    
    angel_min_degree = zeros(max_index, 1);
    
    % Get angle of the nearest point
    for i=0:max_index-1
        
       
        angle_min_range = angle_min + (min_index-1+i) * angle_inc;
        angel_min_degree(i+1) = rad2deg(angle_min_range);
    
    end
    winkel = angel_min_degree;
    

end