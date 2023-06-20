tftree = rostf;
world_coordinates = 'world';
robot_coordinates = 'base_link';

tfmsg = []
while isempty(tfmsg)
    try
        tfmsg = getTransform(tftree, world_coordinates, robot_coordinates);
    catch
        tfmsg = [];
    end
end

position = [tfmsg.Transform.Translation.X, tfmsg.Transform.Translation.Y, tfmsg.Transform.Translation.Z];
orientation = [tfmsg.Transform.Rotation.W, tfmsg.Transform.Rotation.X, tfmsg.Transform.Rotation.Y, tfmsg.Transform.Rotation.Z];

euler = quat2eul(orientation);

print(position)
rad2deg(euler)



