function QuaternionVector = axisAngle2Quaternion(axisAngle)
%from http://www.euclideanspace.com/maths/geometry/rotations/conversions/angleToMatrix/
axis = axisAngle(1:3);
angle = axisAngle(4);

c = cos(angle/2);

s = sin(angle/2);


magnitude = normCPAC(axis);
if magnitude < 0.0001
    error('axis has magnitude 0');
end
axis = axis/magnitude;



%%%%
qx = axis(1)*s;
qy = axis(2)*s;
qz = axis(3)*s;
qw = c;



%%%
QuaternionVector = [qx,qy,qz,qw];







end