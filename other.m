%RUN.m MAIN FIRST

clc;
warning('off','all'); %Get rid of the annoying "new_ff" warning, about
                        %it being used in an obsolete way

%As derived from main best sol is:
net_b = newff(minmax(Input_buffer), [8 1], {'tansig', 'purelin'}, 'traingd');
net_b.trainParam.show = 50;
net_b.trainParam.lr = 0.01;
net_b.trainParam.epochs = 1000; 
net_b.trainParam.goal = 1e-5;

%Use all the data now that the net's structure was finilized
net1 = train(net_b, ts_input, ts_target);
net2 = train(net_b, vs_input, vs_target);
net3 = train(net_b, Input_buffer, Target_buffer); 

resp_b1 = sim(net1, ts_input);
resp_b2 = sim(net2, vs_input);
resp_b3 = sim(net3, Input_buffer);

figure;
plotconfusion(Target_buffer, resp_b3)

figure;
plotroc(Target_buffer, resp_b3)

figure;
plotregression(Target_buffer, resp_b3)

e1 = ts_target - resp_b1;
e2 = vs_target - resp_b2;
e3 = Target_buffer - resp_b3;

ploterrhist(e1, 'training', e2, 'validation', e3, 'testing')