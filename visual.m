%RUN.m MAIN FIRST

clc;
close;
warning('off','all'); %Get rid of the annoying "new_ff" warning, about
                        %it being used in an obsolete way

net_a = newff(minmax(Input_buffer), [8 1], {'tansig', 'tansig'}, 'traingd');
net_a.trainParam.show = 50;
net_a.trainParam.lr = 0.01;
net_a.trainParam.epochs = 1000; 
net_a.trainParam.goal = 1e-5;

%Use all the data now that the net's structure was finilized
nne = train(net_a, Input_buffer, Target_buffer); 
resp_a = sim(nne, Input_buffer);

%Show results of the networks performance
plot( Input_buffer(1, :), resp_a  , 'ro' , Input_buffer(1, :), Target_buffer, 'b*');
legend('predicted value', 'actual value');
ylabel('f', 'fontsize',16)
xlabel('x', 'fontsize',16)
grid;