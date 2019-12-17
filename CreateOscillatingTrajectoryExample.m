%% Create Oscillating Trajectory
% This example shows how to create a trajectory oscillating along the North
% axis of a local NED coordinate system using the |kinematicTrajectory|
% System object(TM).
%

% Copyright 2018 The MathWorks, Inc.

%%
% Create a default |kinematicTrajectory| object. The default initial
% orientation is aligned with the local NED coordinate system.
%

traj = kinematicTrajectory

%%
% Define a trajectory for a duration of 10 seconds consisting of rotation
% around the East axis (pitch) and an oscillation along North axis of the
% local NED coordinate system. Use the default |kinematicTrajectory| sample
% rate.
%

fs = traj.SampleRate; %100
duration = 10;

numSamples = duration*fs;

cyclesPerSecond = 1;
samplesPerCycle = fs/cyclesPerSecond;
numCycles = ceil(numSamples/samplesPerCycle);
maxAccel = 20;

triangle = [linspace(maxAccel,1/fs-maxAccel,samplesPerCycle/2), ...
    linspace(-maxAccel,maxAccel-(1/fs),samplesPerCycle/2)]';
oscillation = repmat(triangle,numCycles,1);
oscillation = oscillation(1:numSamples);

accNED = [zeros(numSamples,2),oscillation];

angVelNED = zeros(numSamples,3);
angVelNED(:,2) = 2*pi;

%%
% Plot the acceleration control signal.
%

timeVector = 0:1/fs:(duration-1/fs);

figure(1)
plot(timeVector,oscillation)
xlabel('Time (s)')
ylabel('Acceleration (m/s)^2')
title('Acceleration in Local NED Coordinate System')


%%
% Generate the trajectory sample-by-sample in a loop. The
% |kinematicTrajectory| System object assumes the acceleration and angular
% velocity inputs are in the local sensor body coordinate system. Rotate
% the acceleration and angular velocity control signals from the NED
% coordinate system to the sensor body coordinate system using
% |rotateframe| and the |Orientation| state. Update a 3-D plot of the
% position at each time. Add |pause| to mimic real-time processing. Once
% the loop is complete, plot the position over time. Rotating the |accNED|
% and |angVelNED| control signals to the local body coordinate system
% assures the motion stays along the Down axis.

figure(2)
plotHandle = plot3(traj.Position(1),traj.Position(2),traj.Position(3),'bo');
grid on
xlabel('North')
ylabel('East')
zlabel('Down')
axis([-1 1 -1 1 0 1.5])
hold on

q = ones(numSamples,1,'quaternion');
for ii = 1:numSamples
     accBody = rotateframe(traj.Orientation,accNED(ii,:));
     angVelBody = rotateframe(traj.Orientation,angVelNED(ii,:));

    [pos(ii,:),q(ii),vel,ac] = traj(accBody,angVelBody);

    set(plotHandle,'XData',pos(ii,1),'YData',pos(ii,2),'ZData',pos(ii,3))
    
    pause(1/fs)
end

figure(3)
plot(timeVector,pos(:,1),'bo',...
     timeVector,pos(:,2),'r.',...
     timeVector,pos(:,3),'g.')
xlabel('Time (s)')
ylabel('Position (m)')
title('NED Position Over Time')
legend('North','East','Down')

%%
% Convert the recorded orientation to Euler angles and plot. Although the
% orientation of the platform changed over time, the acceleration always
% acted along the North axis.
%

figure(4)
eulerAngles = eulerd(q,'ZYX','frame');
plot(timeVector,eulerAngles(:,1),'bo',...
     timeVector,eulerAngles(:,2),'r.',...
     timeVector,eulerAngles(:,3),'g.')
axis([0,duration,-180,180])
legend('Roll','Pitch','Yaw')
xlabel('Time (s)')
ylabel('Rotation (degrees)')
title('Orientation')