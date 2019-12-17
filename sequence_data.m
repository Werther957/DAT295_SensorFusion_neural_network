clc
clear
close all

%addpath('/Users/ImuCalibration/matlab/matlabutils/rotationTools')
%addpath('/Users/ImuCalibration/matlab/matlabutils/misc')

%%%%%%%%%%%%%%%%%%%%  Chosen values  %%%%%%%%%%%%%%%%%%%%
sampling_frequency = 100; % Hz
length_of_rotation = 1;  % s
scale_gyro = [131 125 135]';
scale_acc  = [820 817 822]';
bias_gyro  = [2000 2060 2070]';
bias_acc   = [2000 2060 2070]';

%%%%%%%%%%%%%%%%%%%% Constant values %%%%%%%%%%%%%%%%%%%%
n_motions = 1000;
n_calPos = 500;
n_testPos = n_motions - n_calPos;
dt = 1/sampling_frequency;      % s
n_samples = sampling_frequency * length_of_rotation;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Function for true velocity
x_rotation = @(t,speed)(speed(1).*4.*(-t.^2+t));
y_rotation = @(t,speed)(speed(2).*4.*(-t.^2+t));
z_rotation = @(t,speed)(speed(3).*4.*(-t.^2+t));


% Simulate gyroscope and accelerometer measurements
a = cell(n_motions,1);
phi = cell(n_motions,1);
R_quaternion = cell(n_motions,1);
a_meas = cell(n_motions,1);
phi_meas = cell(n_motions,1);
hrs_rad_list = cell(n_motions,1);
R_tmp = zeros(3,3,n_samples);
R_tot = eye(3);
for j = 1:n_motions
    %highest_rotational_speed = [20 20 20]';         % degrees/s
    highest_rotational_speed = randi([11,60],3,1);  % degrees/s
    sign_of_speed = randi(2,3,1);
    neg_sign = (sign_of_speed==2);
    highest_rotational_speed(neg_sign) = -highest_rotational_speed(neg_sign);
    hrs_rad = deg2rad(highest_rotational_speed);
    t = 0;
    a{j} =  zeros([3,n_samples+1]);
    phi{j} = zeros([3,n_samples+1]);
    R_quaternion{j} = zeros([4,n_samples+1]);
    
    if j == 1
        a{j}(:,1) = [0 0 1]';
    else
        a{j}(:,1) = a{j-1}(:,end);
    end
    
    for i = 1:n_samples
        phi{j}(:,i) = [x_rotation(t,hrs_rad) y_rotation(t,hrs_rad) ...
            z_rotation(t,hrs_rad)]';
        R_tmp(:,:,i) = gyro2rotationMatrix(phi{j}(:,i),dt);
        R_tot = R_tot * R_tmp(:,:,i);
        R_quaternion{j}(:,i) = gyro2rotationMatrix_new(phi{j}(:,i),dt);
        a{j}(:,i+1) = R_tmp(:,:,i) * a{j}(:,i); % mikael stor det ska vara fnutt efter r_temp
    
       t = t+dt;
        
%         plot3(a{j}(1,i),a{j}(2,i),a{j}(3,i),'b.')
%         ylabel('y')
%         zlabel('z')
%         pause(0.001)
%         hold on
%         axis([-1 1 -1 1 -1 1])
    end
    
    phi_meas{j} = phi{j} .* scale_gyro + bias_gyro;
    a_meas{j}   = a{j}   .* scale_acc  + bias_acc;
    hrs_rad_list{j} = hrs_rad;
    
%         plot3(a{j}(1,:),a{j}(2,:),a{j}(3,:),'b.')
%         ylabel('y')
%         zlabel('z')
%         pause(0.001)
%         hold on
%         axis([-1 1 -1 1 -1 1])
end


% Transpose data
for k = 1:n_motions
    a_meas{k} = a_meas{k}';
    a{k} = a{k}';
    R_quaternion{k} =  R_quaternion{k}';
    phi_meas{k} = phi_meas{k}';
    phi{k} = phi{k}';
    hrs_rad_list{k} = hrs_rad_list{k}';
end



% % All calibration data in huge vector
%%
a_meas_all = [];
phi_meas_all=[];
R_quaternion_all=[];
for i=1:1000
    
   a_meas_all = [a_meas_all; a_meas{i}];
   phi_meas_all = [phi_meas_all; phi_meas{i}];
   R_quaternion_all = [R_quaternion_all; R_quaternion{i}];
end
%%
% 
% % Extract calibration positions
% a_n_calPos = cell(n_calPos,1);
% phi_n_calPos = cell(n_calPos,1);
% a_meas_n_calPos = cell(n_calPos,1);
% phi_meas_n_calPos = cell(n_calPos,1);
% hrs_rad_list_n_calPos = cell(n_calPos,1);
% index_n_calPos = randperm(n_motions, n_calPos);
% count = 0;
% for l = index_n_calPos
%     count = count + 1;
%     a_n_calPos{count} = a{l};
%     a_meas_n_calPos{count} = a_meas{l};
%     phi_n_calPos{count} = phi{l};
%     phi_meas_n_calPos{count} = phi_meas{l};
%     hrs_rad_list_n_calPos{count} = hrs_rad_list{l};
% end
% 
% 
% % All calibration data in huge vector
% a_all=[];
% a_meas_all=[];
% phi_all=[];
% phi_meas_all=[];
% hrs_rad_all=[];
% for i=1:n_calPos
%    a_all = [a_all; a_n_calPos{i}];
%    a_meas_all = [a_meas_all; a_meas_n_calPos{i}];
%    phi_all = [phi_all; phi_n_calPos{i}];
%    phi_meas_all = [phi_meas_all; phi_meas_n_calPos{i}];
%    hrs_rad_all = [hrs_rad_all; hrs_rad_list_n_calPos{i}];
% end
% 
% 
% % Extract test postions
% a_test = cell(n_motions - n_calPos,1);
% phi_test = cell(n_motions - n_calPos,1);
% a_meas_test = cell(n_motions - n_calPos,1);
% phi_meas_test = cell(n_motions - n_calPos,1);
% hrs_rad_list_test = cell(n_motions - n_calPos,1);
% index_test = 1:n_motions;
% index_test(index_n_calPos) = [];
% count = 0;
% for l = index_test
%     count = count + 1;
%     a_test{count} = a{l};
%     a_meas_test{count} = a_meas{l};
%     phi_test{count} = phi{l};
%     phi_meas_test{count} = phi_meas{l};
%     hrs_rad_list_test{count} = hrs_rad_list{l};
% end
% 
% 
% % All test data in huge vector
% a_all_test=[];
% a_meas_all_test=[];
% phi_all_test=[];
% phi_meas_all_test=[];
% hrs_rad_all_test=[];
% for i=1:(n_motions - n_calPos)
%    a_all_test = [a_all_test; a_test{i}];
%    a_meas_all_test = [a_meas_all_test; a_meas_test{i}];
%    phi_all_test = [phi_all_test; phi_test{i}];
%    phi_meas_all_test = [phi_meas_all_test; phi_meas_test{i}];
%    hrs_rad_all_test = [hrs_rad_all_test; hrs_rad_list_test{i}];
% end
% 
% 
% a = a_n_calPos;
% a_meas = a_meas_n_calPos;
% phi = phi_n_calPos;
% phi_meas = phi_meas_n_calPos;



%save('IMU_data_4000_rotations_to_500_rotation_20','dt','a',...
%    'a_meas','phi','phi_meas', 'a_all', 'a_meas_all', 'phi_all', ...
%   'phi_meas_all', 'hrs_rad_all', 'a_test', 'a_meas_test', 'phi_test',...
%    'phi_meas_test', 'a_all_test', 'a_meas_all_test', 'phi_all_test', ...
%    'phi_meas_all_test', 'n_calPos', 'n_testPos')

