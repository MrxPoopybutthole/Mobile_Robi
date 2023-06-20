clearvars -except perception_node
clf
% create node for perception functionality
%perception_node = ros.Node("/perception");

% create subscriber for the laser scanner
sub_laser = ros.Subscriber(perception_node, '/base_scan');

scandata = receive(sub_laser,10);

%while true
    xy = readCartesian(scandata);
    alpha = alphahist(xy, 27)
    
    % take all points where x is between 0 and 2 AND 
    % where y is between 0 and 1 to get all points in
    % a region of interest (ROI)
    left_roi = ( xy(:,1)>0 & xy(:,1)<2 ) & ( xy(:,2)>0 & xy(:,2)<1 ); % --> boolean array
    left_found_points = xy(left_roi, :);   % extract coordinates where conditions are met
    

    
     if length(left_found_points) > 20  % if ROI left has less than 20 points
         mean_points = extract_lane_points(left_found_points);
         fprintf("Detected left lane");
     else % if points in the right ROI
         right_roi = ( xy(:,1)>0 & xy(:,1)<2 ) & ( xy(:,2)<0 & xy(:,2)>-1 );
         right_found_points = xy(right_roi, :);   % extract coordinates where conditions are met
         %alpha = alphahist(right_found_points, 0)
     end
     
     % check if there are any valid points in the right ROI, if not then
     % there were no points neither left or right, so turn
     if length(left_found_points) < 20 && length(right_found_points) > 20
         mean_points = extract_lane_points(right_found_points);
         fprintf("Detected right lane");
     elseif length(left_found_points) < 20 && length(right_found_points) < 20
         % turn
         fprintf("No lane detected. Please turn!");
     end
     alphas = calc_alphas(left_found_points)
     clf
     histogram(alphas, 0:5:90);
     
     
     
     
     
     
     
    
  
    
%end
