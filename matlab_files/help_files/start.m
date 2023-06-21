sub_laser = rossubscriber('/base_scan');
pub = rospublisher('/cmd_vel', 'geometry_msgs/Twist');
msg = rosmessage(pub);

odom_sub = rossubscriber('/odom'); 
odom_msg = receive(odom_sub); 

k = 200;
roi_view_x = 2;
roi_view_y = 1;
old_alpha = 0;
x_distance = 0.5;  % x-Abstand für den zweiten Punkt
kp = 1;
duration = 10;  
rate = rateControl(10);  

msg.Linear.X = 0.5;

figure(1);
figure(2);
for i = 1:duration
    scandata = receive(sub_laser,10);
    xy = readCartesian(scandata);
    roi = (xy(:,1) > 0 & xy(:,1) < roi_view_x) & (abs(xy(:,2)) < roi_view_y);
    found_points = xy(roi,:);
    alpha = alphahist(xy, old_alpha, k)
    old_alpha = alpha;
    % Finden Sie die Punkte auf der linken und rechten Seite
    left_points = found_points(found_points(:,2) >= 0,:);
    right_points = found_points(found_points(:,2) < 0,:);
    % Überprüfen Sie, ob links und rechts Punkte vorhanden sind
    if isempty(left_points) || isempty(right_points)
        continue;
    end

    % Finde den ersten Punkt und einen Punkt, der x_distance entfernt ist, auf beiden Seiten
    [~, left_first_idx] = min(left_points(:,1));
    [~, left_next_idx] = min(abs(left_points(:,1) - (left_points(left_first_idx,1) + x_distance)));

    [~, right_first_idx] = min(right_points(:,1));
    [~, right_next_idx] = min(abs(right_points(:,1) - (right_points(right_first_idx,1) + x_distance)));
    
    % Überprüfen Sie, ob die oberen Punkte über dem Roboter und die unteren Punkte unter dem Roboter sind
    if left_points(left_first_idx,2) < 0 || left_points(left_next_idx,2) < 0 || right_points(right_first_idx,2) > 0 || right_points(right_next_idx,2) > 0
        continue;
    end

    % Berechnen Sie die Mittelpunkte der beiden Linien, die durch die Punkte verlaufen
    mid_point1 = [(left_points(left_first_idx,1)+right_points(right_first_idx,1))/2, (left_points(left_first_idx,2)+right_points(right_first_idx,2))/2];
    mid_point2 = [(left_points(left_next_idx,1)+right_points(right_next_idx,1))/2, (left_points(left_next_idx,2)+right_points(right_next_idx,2))/2];
    
    % Bestimmen Sie die Steigung der Mittellinie
    slope = (mid_point1(2) - mid_point2(2)) / (mid_point1(1) - mid_point2(1));

    % Bestimmen Sie den Winkel der Mittellinie in Bezug auf die x-Achse
    desired_orientation = atan(slope);

    robot_orientation = 0;
    
    % Bestimmen Sie den Winkel, den der Roboter drehen muss
    turn_angle = desired_orientation - robot_orientation;
    if(abs(turn_angle )> 0.2)
         msg.Angular.Z = kp * turn_angle;
    else
        msg.Angular.Z = 0;
    end

    % Senden Sie die Geschwindigkeitsnachricht
    send(pub, msg);
    figure(1);
    plot(found_points(:,1), found_points(:,2), 'k.');
    hold on;
    plot(left_points(left_first_idx, 1), left_points(left_first_idx, 2), 'ro', 'LineWidth', 2, 'MarkerSize', 10);
    plot(left_points(left_next_idx, 1), left_points(left_next_idx, 2), 'mo', 'LineWidth', 2, 'MarkerSize', 10);
    plot(right_points(right_first_idx, 1), right_points(right_first_idx, 2), 'ro', 'LineWidth', 2, 'MarkerSize', 10);
    plot(right_points(right_next_idx, 1), right_points(right_next_idx, 2), 'mo', 'LineWidth', 2, 'MarkerSize', 10);
    plot([mid_point1(1), mid_point2(1)], [mid_point1(2), mid_point2(2)], 'r-');
    hold off;   
    
    drawnow;
    
    % Fahren Sie fort mit dem Senden von Befehlen an den Roboter...
    send(pub, msg);
    waitfor(rate);
end

msg.Linear.X = 0;
msg.Angular.Z = 0;
send(pub, msg);