laser = rossubscriber('/base_scan');
robotPos = rossubscriber('/odom');

roi_view_x = 2;
roi_view_y = 1;


scandata = receive(laser,10);
xy = readCartesian(scandata)



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

values = -0.25:.005:max(mittel_linie(:,2));
figure(5);
histogram(mittel_linie(:,2), values);

mean(mittel_linie(:,2))






% 
% values = 1:length(found_points);
% figure(1);
% bar(values,found_points(:,2))
% 
% values = 1:length(points_left_linie);
% figure(2);
% bar(values,points_left_linie(:,2))
% 
% values = 1:length(points_right_linie);
% figure(3);
% bar(values,points_right_linie(:,2))
% 
% 
% values = 1:length(mittel_linie);
% figure(4);
% bar(values,mittel_linie(:,2))
% 

% values = -0.25:.005:max(mittel_linie(:,2));
% figure(5);
% histogram(mittel_linie(:,2), values);
% 
% mean(mittel_linie(:,2))

% values = -0.25:.005:max(points_left_linie(:,2));
% figure(6);
% histogram(points_left_linie(:,2), values);
% 
% values = -0.25:.005:max(points_right_linie(:,2));
% figure(7);
% histogram(points_right_linie(:,2), values);
% 
