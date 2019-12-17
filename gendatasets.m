motions = 100;
waypoints = zeros(motions,3); 
orientations  = zeros(motions,3); 
deltaorientations  = zeros(motions,3); 

maxspeed = 60;
maxangularvelocity = pi/4;
motion_cycle = 1;

maxpositionchange = maxspeed*motion_cycle;
maxorienchange = maxangularvelocity*motion_cycle;

for i = 2:motions
    waypoints(i,:) = waypoints(i-1,:)+2*maxpositionchange*rand(1,3)- maxpositionchange/5;
    deltaorientations(i,:) = 2*maxorienchange*rand(1,3)- maxorienchange/5;
    orientations(i,:) = orientations(i-1,:)+deltaorientations(i,:);
end

toa = 0:motions-1; % time of arrival

orientation = quaternion(orientations,'eulerd','ZYX','frame');
%deltaorientations_quaternion = quaternion(deltaorientations,'eulerd','ZYX','frame');                   
                      
trajectory = waypointTrajectory(waypoints, ...
    'TimeOfArrival',toa, ...
    'Orientation',orientation, ...
    'SampleRate',10);



orientationLog = zeros(toa(end)*trajectory.SampleRate,1,'quaternion');
count = 1;
while ~isDone(trajectory)
   [currentPosition(count,:),orientationLog(count),speed,acceler(count,:),angl_velocity(count,:)] = trajectory();

   %plot(currentPosition(1),currentPosition(2),'bo')

   %pause(trajectory.SamplesPerFrame/trajectory.SampleRate)
   count = count + 1;
end

plot3(currentPosition(:,1),currentPosition(:,2),currentPosition(:,3),'bo')
hold off


[qA,qB,qC,qD] = parts(orientationLog);