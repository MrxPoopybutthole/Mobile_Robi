laser = rossubscriber('/base_scan');
robotPos = rossubscriber('/odom');

%Fahrbefehle in Form von Geschwindigkeiten
robotCmd = rospublisher('/cmd_vel', 'geometry_msgs/Twist');
vel_msg = rosmessage(robotCmd);

%Abstand zur Reihenmitte
distance_row_center = rospublisher('/offset', 'std_msgs/Float64');
distanceMsg = rosmessage(distance_row_center);

%Orientierung zur Reihenmitte
orientation_row_center = rospublisher('/alpha', 'std_msgs/Float64');
orientationMsg = rosmessage(orientation_row_center);

%true, wenn innerhalb der Reihe
pub_inside_row = rospublisher('/inside_row', 'std_msgs/Bool');
insideRowMsg = rosmessage(pub_inside_row);

% Definiere die Breite, die links und rechts hinzugefügt werden soll
intervall_Breite = 0.05; % Ändern Sie diesen Wert nach Bedarf
roi_view_x = 2.5;
roi_view_y = 0.8;
turn_counter = 1;
robot_speed = 0.5;
robot_width = 0.3;
values = 1:720;
k = 20;
kp = 0.8;
old_alpha = 0;
lenk_toleranz = 0.055;
points_left = [];
points_right = [];
mittel_linie = [];
x_distance = 0.5; 

while true
    scandata = receive(laser,10);
    ranges = scandata.Ranges;
    ranges(720);
    vel_msg = rosmessage(robotCmd);
    vel_msg.Linear.X = robot_speed;
    send(robotCmd,vel_msg);
    
    if min(ranges)>2 
        insideRowMsg.Data = false;
        send(pub_inside_row, insideRowMsg);
   
        if mod(turn_counter, 2) == 0
            direction = -1;
        else
            direction = 1;
        end 
        
        distance = 0.5;
        velocity = 0.5;
        radius = 0.4;
        linearSpeed = velocity;
        angularSpeed = velocity/radius;
        durationStraight = distance/ linearSpeed;
        
        vel_msg.Angular.Z = 0;
        sendTime = rostime('now');
        while (rostime('now') - sendTime < durationStraight)
            send(robotCmd, vel_msg);
        end 
        
        durationCurve = pi/angularSpeed;
        vel_msg.Linear.X = linearSpeed;
        vel_msg.Angular.Z = direction * angularSpeed;
        sendTime = rostime('now');
        
        while (rostime('now') - sendTime < durationCurve - 0.15) 
            send(robotCmd, vel_msg);
        end
        turn_counter = turn_counter + 1;
        
    elseif min(ranges) < 2
        insideRowMsg.Data = true;
        send(pub_inside_row, insideRowMsg);
        
        xy = readCartesian(scandata);
        
        roi = (xy(:,1) > 0 & xy(:,1) < roi_view_x) & (abs(xy(:,2)) < roi_view_y);
        found_points = xy(roi,:);
        
        %%%
        left_points = found_points(found_points(:,2) >= 0,:);
        right_points = found_points(found_points(:,2) < 0,:);
        if isempty(left_points) || isempty(right_points)
            continue;
        end
        [~, left_first_idx] = min(left_points(:,1));
        [~, left_next_idx] = min(abs(left_points(:,1) - (left_points(left_first_idx,1) + x_distance)));
        [~, right_first_idx] = min(right_points(:,1));
        [~, right_next_idx] = min(abs(right_points(:,1) - (right_points(right_first_idx,1) + x_distance)));
        if left_points(left_first_idx,2) < 0 || left_points(left_next_idx,2) < 0 || right_points(right_first_idx,2) > 0 || right_points(right_next_idx,2) > 0
            continue;
        end
        mid_point1 = [(left_points(left_first_idx,1)+right_points(right_first_idx,1))/2, (left_points(left_first_idx,2)+right_points(right_first_idx,2))/2];
        mid_point2 = [(left_points(left_next_idx,1)+right_points(right_next_idx,1))/2, (left_points(left_next_idx,2)+right_points(right_next_idx,2))/2];
        %%%
        figure(1);
        plot(found_points(:,1), found_points(:,2), 'k.');
        hold on;
        plot(left_points(left_first_idx, 1), left_points(left_first_idx, 2), 'ro', 'LineWidth', 2, 'MarkerSize', 10);
        plot(left_points(left_next_idx, 1), left_points(left_next_idx, 2), 'mo', 'LineWidth', 2, 'MarkerSize', 10);
        plot(right_points(right_first_idx, 1), right_points(right_first_idx, 2), 'ro', 'LineWidth', 2, 'MarkerSize', 10);
        plot(right_points(right_next_idx, 1), right_points(right_next_idx, 2), 'mo', 'LineWidth', 2, 'MarkerSize', 10);
        plot([mid_point1(1), mid_point2(1)], [mid_point1(2), mid_point2(2)], 'r-');
        hold off; 
        %%%
        
        alpha = alphahist(found_points, old_alpha, k);
        old_alpha = alpha;
        
%         for i = 1:length(found_points)
%             if found_points(i,2) > 0
%                 points_left = [points_left; found_points(i,1), (found_points(i,2) - 0.375)];
%                 mittel_linie = [mittel_linie; found_points(i,1), (found_points(i,2) - 0.375)];
%             else
% 
%                 points_right = [points_right; found_points(i,1), (found_points(i,2) + 0.375)];
%                 mittel_linie = [mittel_linie; found_points(i,1), (found_points(i,2) + 0.375)];
%             end
% 
%         end
        left_points_mask = found_points(:,2) > 0;
        points_left = [found_points(left_points_mask, 1), (found_points(left_points_mask, 2) - 0.375)];
        points_right = [found_points(~left_points_mask, 1), (found_points(~left_points_mask, 2) + 0.375)];
        mittel_linie = [found_points(:,1), found_points(:,2) - 0.375 * left_points_mask + 0.375 * ~left_points_mask];

        if isempty(mittel_linie) == false
            min_line = min(mittel_linie(:,2));
            max_line = max(mittel_linie(:,2));
            mitte = mittel_linie(:,2);
            values = min_line:.005:max_line;
            if numel(values) >= 2
                figure(3);
                hist = histogram(mitte, values);
                hold on;  
            end
        end
        anzahl = hist.Values;
        mitten = hist.BinEdges(1:end-1) + diff(hist.BinEdges)/2;      
        [maxAnzahl, idx] = max(anzahl);
        maxBinMittelpunkt = mitten(idx);
        intervalStart = maxBinMittelpunkt - intervall_Breite;
        intervalEnd = maxBinMittelpunkt + intervall_Breite;
        datenImIntervall = mittel_linie(mittel_linie >= intervalStart & mittel_linie <= intervalEnd);
        datenImIntervall_mean = mean(datenImIntervall);
        
        patch([intervalStart intervalStart intervalEnd intervalEnd], [0 maxAnzahl maxAnzahl 0], 'r', 'FaceAlpha',0.3);
        hold off;
            
        if datenImIntervall_mean < -lenk_toleranz
            vel_msg = rosmessage(robotCmd);
            vel_msg.Angular.Z = -kp;
            send(robotCmd,vel_msg);

        elseif datenImIntervall_mean > lenk_toleranz
            vel_msg = rosmessage(robotCmd);      
            vel_msg.Angular.Z = kp;
            send(robotCmd,vel_msg);   
        end
    end
end