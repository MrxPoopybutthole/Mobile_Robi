
laser = rossubscriber('/base_scan');
robotPos = rossubscriber('/odom');

scandata = receive(laser,10);
angles = linspace(scandata.AngleMin, scandata.AngleMax, numel(scandata.Ranges));
xy = readCartesian(scandata);
ranges = scandata.Ranges
ranges(720);

values = 1:720;
%histogram(720,ranges);

bar(values,ranges);