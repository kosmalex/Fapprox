function [Input_buffer, Target_buffer] = genData(f)
    %This is a wapper function for cleaner code

    Input_buffer = zeros(3, 200); %Initialize input buffer with 0s and fill it with uniformly
    for index = 1:length(Input_buffer)     %distributed values ranging from [-1, 1]
        Input_buffer(:, index) = -1 * (1 - rand(1, 3)) + rand(1, 3) * 1;
    end

    Target_buffer = zeros(1, 200); %Calculate the corresponding targets to the above inputs
    for index = 1:length(Input_buffer)
        %It's pretier with x, y, z
        x = Input_buffer(1, index);
        y = Input_buffer(2, index);
        z = Input_buffer(3, index);

        Target_buffer(:, index) = f(x, y, z);
    end
