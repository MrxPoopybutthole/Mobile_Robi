laser = rossubscriber('/base_scan')
scandata = receive(laser,10)

dist_vec = scandata.Ranges;
[mini, idx] = min(dist_vec);
plot(scandata);
hold on

mini_angle = scandata.AngleMin + scandata.AngleIncrement * idx
rad2deg(mini_angle)
x_value = cos(mini_angle) * mini
y_value = sin(mini_angle) * mini
plot(x_value, y_value, 'r*');