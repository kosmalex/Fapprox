function [in_arr, t_arr] = randFill(input_arr, target_arr, N)
    t_arr = zeros(size(target_arr, 1), N);
    in_arr = zeros(size(input_arr, 1), N);

    indeces = ceil(rand(1, N) * length(target_arr));
        
    for i=1:N
        t_arr(i) = target_arr(indeces(i));
        in_arr(:, i) = input_arr(:, indeces(i));
    end
end

