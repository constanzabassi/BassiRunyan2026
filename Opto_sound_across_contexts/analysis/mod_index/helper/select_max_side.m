function [cv_mod_index, cv_mod_index_separate,side] = select_max_side(cv_mod_left, cv_mod_right, nNeurons)
    % Initialize outputs
    cv_mod_index = zeros(1, nNeurons);
    side = cell(1, nNeurons);
    
    % Select side with larger absolute modulation for each neuron
    for n = 1:nNeurons
        if abs(cv_mod_left(n)) >= abs(cv_mod_right(n))
            cv_mod_index(n) = cv_mod_left(n);
            side{n} = 'left';
        else
            cv_mod_index(n) = cv_mod_right(n);
            side{n} = 'right';
        end
    end
    
    % Package results
    cv_mod_index_separate = struct(...
        'left', cv_mod_left, ...
        'right', cv_mod_right, ...
        'max', cv_mod_index, ...
        'side', {side});
end