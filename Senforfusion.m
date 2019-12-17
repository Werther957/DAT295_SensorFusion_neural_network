%%
xTrain = [phi_meas_all,a_meas_all]';
tTrain = R_quaternion_all';


%remove the columes cnntain NAN
NaNCols = any(isnan(tTrain));
tTrain = tTrain(:,~NaNCols);
xTrain = xTrain(:,~NaNCols);


%divide the data set 
[trainInd,valInd,testInd] = dividerand(size(xTrain,2),0.6,0.2,0.2);
%%

%%construct the network
net = feedforwardnet([10 10])
net.performParam.normalization = 'standard';
%net.inputs{1}.processFcns = {'mapminmax'};
%net.outputs{3}.processFcns = {'mapminmax'};
[net,tr,Y,E] = train(net,xTrain(:,trainInd),tTrain(:,trainInd));


%%
test_predict = net(xTrain(:,testInd))
test_target = tTrain(:,testInd)
%result = Y(1,:)
%mytarget = tTrain(1,:)
temp1 = Cal_nrmse(test_predict(1,:), test_target(1,:))
temp2 = Cal_nrmse(test_predict(2,:), test_target(2,:))
temp3 = Cal_nrmse(test_predict(3,:), test_target(3,:))
temp4 = Cal_nrmse(test_predict(4,:), test_target(4,:))
%temp = Cal_nrmse(Y, tTrain)

%rmse = rms(Y - tTrain)
%nrmse = 

figure(1)
plot(test_target(4,:)','linewidth',2)
hold on
plot(test_predict(4,:)','r--')
grid on
legend('Targets','Network response')
%ylim([-1.25 1.25])


function lnrmse = Cal_nrmse(result, mytarget)

    lrmse = rms(mytarget-result);
    lnrmse = lrmse/mean(result);

end