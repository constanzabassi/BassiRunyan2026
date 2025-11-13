function [rows,columns] = determine_num_tiles(num_observation)
% Number of things to plot
num_plots = num_observation;%length(observation);  % Change this value based on your requirement

% Calculate the number of rows and columns for the tiled layout
rows = ceil(sqrt(num_plots));
columns = ceil(num_plots / rows);
