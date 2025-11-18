function subtracted_avg = find_average_difference(avg_results, avg_results2)
% FIND_AVERAGE_DIFFERENCE Computes the difference in average neuron responses 
% between two conditions across contexts.
%
% INPUTS:
%   avg_results  - Cell array containing neural response data for the first condition.
%                  Structure: avg_results{1,1} (active), avg_results{1,2}
%                  (passive) and avg_results{1,3} (spontaneous).
%                  Each contains fields: 'left' and 'right', which have 
%                  .neuron_mean (vector of mean responses per neuron).
%   avg_results2 - Cell array containing neural response data for the second condition.
%                  Same structure as avg_results.
%
% OUTPUT:
%   subtracted_avg - Struct containing the difference in average responses.

directions = {'Left', 'Right'};
subtracted_avg = {}; % Ensure it's a struct, not a cell array

for dir = 1:2    
    % Convert direction name to lowercase for field access
    dir_name = lower(directions{dir});
    
    % Compute differences
    for context = 1:min(length(avg_results),length(avg_results2))
        subtracted_avg{1,context}.(dir_name).neuron_mean = [avg_results{1,context}.(dir_name).neuron_mean - avg_results2{1,context}.(dir_name).neuron_mean];
    end
end

end
