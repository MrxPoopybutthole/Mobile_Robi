function [avg_values] = extract_lane_points(found_points)
close all;
 
%EXTRACT_LANE Summary of this function goes here
%   Detailed explanation goes here
whos
DS = [1 Inf]; % set absolute tolerance for the coordinate range
% "OutputAllIndices" means that the indices of the values within the
% set range are also stored in IA
% tolerance can be changed
[C, object_indices] = uniquetol(found_points, 0.1, 'ByRows', true, ...
    'OutputAllIndices', true, 'DataScale', DS);
hold on
avg_values = []; % final xy values for the obstacles on the left side
for k = 1:length(object_indices)
    k
    plot(found_points(object_indices{k},1), found_points(object_indices{k},2), '.');
    object_indices{k}
    object_indices(k)
    points_within_tolerance = found_points(object_indices{k},:)
    
    % if at least 4 points are found for the object
    if length(points_within_tolerance) >= 4 
        meanAi = mean(points_within_tolerance)
        plot(meanAi(1), meanAi(2), 'xb')
        avg_values = [avg_values; meanAi];
    end
end
% plot(avg_values(:, 1), avg_values(:, 2), 'xb');
% xlim([0, 2]);
% ylim([-2, 2]);
% 


end

