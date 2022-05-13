clear;
clc;
close;
warning('off','all'); %Get rid of the annoying "new_ff" warning, about
                        %it being used in an obsolete way

tot_samples = 200;

%For cross-validation
ts_size = .8 * tot_samples;
vs_size = .2 * tot_samples;

f = @(x, y, z) z.^2 + x.^3 - 2*x.*cos(y.*z + 4); %The function to be approximated

%generate input output pairs
[Input_buffer, Target_buffer] = genData(f);

%80percent of data is used as training set
%20percent of data is used as validation set
[ts_input, ts_target] = randFill(Input_buffer, Target_buffer, ts_size); 
[vs_input, vs_target] = randFill(Input_buffer, Target_buffer, vs_size);

%<Cross Validation>
MAX_ITER = 100;
Sol_buffer = cell([1, MAX_ITER]);
sol_counter = zeros(1, MAX_ITER); 
for l =1:MAX_ITER
    l %for referance.
    
    step = 3; %Increment step of the neuron number
    nTansig = 5; %number of Neurons
    nLayers = 2; %number of Layers
    old_mse1 = inf; %mean square error of the network for ts_set, used for comparison
    old_mse2 = inf; %mean square error of the network for vs_set, used for comparison
    sol = {}; %A cell array with the number of Layers and the number of neurons per layer

    a = {'tansig', 'purelin'}; %Initial layers
    b = [nTansig, 1]; %Initial number of Neurons per layer

    updateX = true; %Lock for updating the number of Layers
    while true     
        %Init network
        neural_net = newff(minmax(ts_input), b, a, 'traingd'); %Our Network
        neural_net.trainParam.show = 50; % The result is shown at every 50th iteration (epoch) 
        neural_net.trainParam.lr = 0.01; % Learning rate used in some gradient schemes 
        neural_net.trainParam.epochs = 1000; % Max number of iterations 
        neural_net.trainParam.goal = 1e-5; % Error tolerance; stopping criterion 

        trained_net = train(neural_net, ts_input, ts_target); %Train it

        ts_resp = sim(trained_net, ts_input); %sim with training set (ts)
        vs_resp = sim(trained_net, vs_input); %sim with validation set (vs)

        %<calc new mean square error>
        mse1 = mse(trained_net, ts_target, ts_resp); 
        mse2 = mse(trained_net, vs_target, vs_resp); 
        %<calc new mean square error/>

        %if condition is matched, do ...
        if (mse1 < old_mse1) && (mse2 < old_mse2) %first try always succeeds
            nTansig = nTansig + step; %increment number of neurons
            updateX = true; %We are allowed to update the number of Layers
                            %if the above condition fails

            b(nLayers - 1) = nTansig; %Only the second, from the right, layer
                                      %has its number of neurons incremented

            %update old mses(plural)
            old_mse1 = mse1;
            old_mse2 = mse2;

            %set the solution
            sol = {b, a};
        else
            if ~updateX %If adding a Layer didn't reduce both mses enough
                break   %break out of the loop
            else %If we are allowed to increase nLayer
                nLayers = nLayers + 1; %incremnet
                updateX = false; %Disable Layer increment

                a{nLayers - 1} = 'tansig'; %The newly added layer is of type 'tansig'
                b(nLayers - 1) = ceil(nTansig/2); %and has ceil(nTansig/2) neurons

                %Last Layer is ALWAYS A PURELIN with ONE NEURON
                a{nLayers} = 'purelin';
                b(nLayers) = 1;
            end
        end
    end
    
    if l ~= 1 %Check if this is the first iter
        %Regarding functionality, variable naming speaks for itself
        hasMatch = any(cellfun(@isequal, Sol_buffer, repmat({sol}, size(Sol_buffer))));
        matchIdx = cellfun(@isequal, Sol_buffer, repmat({sol}, size(Sol_buffer)));
        
        if hasMatch %If match was found increment its counter
            sol_counter(matchIdx) = sol_counter(matchIdx) + 1;
        else %Else store it and init its counter to 1
            Sol_buffer{l} = sol;
            sol_counter(l) = 1;
        end
    else %If it's the first iter no need to bother, just fill the first element
        Sol_buffer{1} = sol;
        sol_counter(1) = 1;
    end
    
end
%<Cross Validation/>

%<Extract Solution>
[~, maxIdx] = max(sol_counter); %Let's see who got the most points
finSol = Sol_buffer{maxIdx};
%<Extract Solution/>

%Train the network of the final solution
neural_net = newff(minmax(Input_buffer), finSol{1}, finSol{2}, 'traingd');
neural_net.trainParam.show = 50;
neural_net.trainParam.lr = 0.01;
neural_net.trainParam.epochs = 1000; 
neural_net.trainParam.goal = 1e-5;

%Use all the data now that the net's structure was finilized
finNet = train(neural_net, Input_buffer, Target_buffer);

%generate new input data only, and sim the network
[Input_buffer, Target_buffer] = genData(f);
resp = sim(finNet, Input_buffer);

%Show results of the networks performance
subplot(131)
plot( Input_buffer(1, :), resp  , 'ro' , Input_buffer(1, :), Target_buffer, 'b*');
legend('predicted value', 'actual value');
ylabel('f', 'fontsize',16)
xlabel('x', 'fontsize',16)
grid;

subplot(132)
plot( Input_buffer(2, :), resp  , 'ro' , Input_buffer(2, :), Target_buffer, 'b*');
title('$f(x, y, z) = z^2 + x^3 - 2x{\times}cos(yz + 4)$', 'interpreter', 'latex', ...
      'fontsize',16)
xlabel('y', 'fontsize',16)
grid;

subplot(133)
plot( Input_buffer(3, :), resp  , 'ro' , Input_buffer(3, :), Target_buffer, 'b*');
xlabel('z', 'fontsize',16)
grid;
