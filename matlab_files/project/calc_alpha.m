function [alpha] = calc_alpha(mean_points)
%calc_alpha computes average alpha
% first computes all angles between all found points
% then filter out all angles between 85 and 95 degrees as they represent
% the sides of the obstacles which are not useful for lane detection
% then do a histcount where 
alpha = atan2d(mean_points(1, 2) - mean_points(end, 2), ...
             mean_points(1, 1) - mean_points(end, 1));

% remap all alphas to either [-90, 0] or [0, 90] depending on the sign
if alpha > 0
    alpha = 180 - alpha;
elseif alpha < 0
    alpha = -180 - alpha;
else
    alpha = alpha;
end
% noch abfangen ob rechte oder linke Lane

end

