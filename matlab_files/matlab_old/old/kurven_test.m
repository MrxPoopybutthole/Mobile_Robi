
velPub = rospublisher('/cmd_vel', 'geometry_msgs/Twist');
velMsg = rosmessage(velPub);

velocity = 0.5;
radius = 0.8;

linearSpeed = velocity;
angularSpeed = velocity/radius;

angle = pi;
duration = angle/angularSpeed;

velMsg.Linear.X = linearSpeed;
velMsg.Angular.Z = angularSpeed;
sendTime = rostime('now');
while (rostime('now') - sendTime < duration)
    send(velPub, velMsg);
end
