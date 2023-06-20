clearvars -except perception_node
clf

% --------------ToDo------------------
% - Unterscheidung von linken und rechten Pollern in calc_alpha()
% - Histogramme anzeichen
% - Poller einzeln anschauen:
%     1. Punkt x mit geringstem y-Wert für Poller 1 identifizieren
%     2. alle Punkte, deren y-Wert + 1cm größer ist, werden verworfen
%     3. Problem? Dass Poller zu wenig Punkte haben könnten --> vielleicht
%         y-Wert + 2cm?

% create node for perception functionality
if isempty(perception_node)
    perception_node = ros.Node("/perception");
end

% create subscriber for the laser scanner
sub_laser = ros.Subscriber(perception_node, '/base_scan');

scandata = receive(sub_laser,10);
roi_view_x = 2;
roi_view_y = 0.5;

old_alpha = 0;
alpha = 0;
%while true
    xy = readCartesian(scandata);
    
    % take all points where x is between 0 and 2 AND 
    % where y is between 0 and 1 to get all points in
    % a region of interest (ROI)
    left_roi = ( xy(:,1)>0 & xy(:,1)<roi_view_x ) & ( xy(:,2)>0 & xy(:,2)<roi_view_y ); % --> boolean array
    left_found_points = xy(left_roi, :);   % extract coordinates where conditions are met
    right_roi = ( xy(:,1)>0 & xy(:,1)<roi_view_x ) & ( xy(:,2)<0 & xy(:,2)>-roi_view_y );
    right_found_points = xy(right_roi, :);   % extract coordinates where conditions are met
    %all_points = vertcat(left_found_points, right_found_points);
    

% if ROI right has less than 50 points --> validated by empirical testing
% if not enough points on the right side, check points on the left side
% if there are not enough points at all use old alpha
if length(right_found_points) > 50
    mean_points = extract_lane_points(right_found_points);
    alpha = calc_alpha(mean_points);
    old_alpha = alpha;
    fprintf("Detected right lane");
elseif length(left_found_points) > 50
    mean_points = extract_lane_points(left_found_points);
    alpha = calc_alpha(mean_points);
    old_alpha = alpha;
    fprintf("Detected left lane");
else    
    alpha = old_alpha;
    fprintf("No lane detected because of not enough points.");
end

    
     
  
    
%end
