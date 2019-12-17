function R = gyro2rotationMatrix(gyro, dt)
%#codegen
if isa(gyro,'single')
    epsilon = 3e-4; % smallest value for which cos(ag) - ag ~= 0
else %double
    epsilon = 1e-8;
end
gyroNorm = normCPAC(gyro);
%gyroNorm = (gyro);
gyroNormDt = gyroNorm*dt;
%if gyroNormDt > epsilon
    axisAngle = [gyro/gyroNorm; gyroNormDt];
    R = axisAngle2Quaternion(axisAngle);
%else
   % R = infinitesimalRotation2rotationMatrix(gyro*dt);
%end

end