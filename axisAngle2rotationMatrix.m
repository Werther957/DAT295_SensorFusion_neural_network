function rotationMatrix = axisAngle2rotationMatrix(axisAngle)
%from http://www.euclideanspace.com/maths/geometry/rotations/conversions/angleToMatrix/
axis = axisAngle(1:3);
angle = axisAngle(4);
c = cos(angle);
s = sin(angle);
t = ones(1,'like',c) - c;

magnitude = normCPAC(axis);
if magnitude < 0.0001
    error('axis has magnitude 0');
end
axis = axis/magnitude;

sAxis = s*axis;
tAxis = t*axis;

xyt = tAxis(1)*axis(2);
yzt = tAxis(2)*axis(3);
zxt = tAxis(3)*axis(1);

xxt = tAxis(1)*axis(1);
yyt = tAxis(2)*axis(2);
zzt = tAxis(3)*axis(3);

rotationMatrix = [        c + xxt, xyt - sAxis(3), zxt + sAxis(2);
                   xyt + sAxis(3),        c + yyt, yzt - sAxis(1);
                   zxt - sAxis(2), yzt + sAxis(1),       c + zzt];
end