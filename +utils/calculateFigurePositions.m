function positions = calculateFigurePositions(rows, cols, spacing, second_spacing, rectangle_ratio)
% Calculates figure positions on an 8.5 x 11 inch paper
% Adjusts for default MATLAB figure size (6.5 x 4 inches)
% Adds extra spacing if labels are present (second_spacing)
% Optionally allows for rectangular figures via rectangle_ratio

    % Constants
    if rows > 3
        paper_height = 8;  % inches
    else
        paper_height = 4.5;
    end
    
    % Calculate available width and height after spacing
    available_width = 8.5 - (cols + 1) * spacing - 0.7; % -0.7 for margins
    available_height = 11 - (rows + 1) * spacing - 0.5; % -0.5 for margins
    
    % Determine the figure size
    figure_size = min(available_width / cols, available_height / rows);
    
    % Check if rectangle_ratio is provided; default is square (1:1)
    if nargin < 5 || isempty(rectangle_ratio)
        rectangle_ratio = 1; % Square figures
    end
    
    figure_width = figure_size;
    figure_height = figure_size * rectangle_ratio;
    
    % Initialize positions array
    positions = zeros(rows * cols, 4); % [x, y, width, height]
    
    % Calculate positions for each figure
    index = 1;
    for r = 1:rows
        for c = 1:cols
            if spacing < 0.5
                x = spacing + (c - 1) * (figure_width + spacing) + 0.3; %+ 0.1 in case y labels get cut out
            else
                x = spacing + (c - 1) * (figure_width + spacing) + 0.2;
            end
            
            if ~isempty(second_spacing) && c > 1
                x = x + (c - 1) * second_spacing; % Add extra spacing for labels
            end
            
            y = paper_height - (spacing + r * figure_height + (r - 1) * spacing);
            
            positions(index, :) = [x, y, figure_width, figure_height];
            index = index + 1;
        end
    end
end
% function positions = calculateFigurePositions(rows, cols, spacing, second_spacing)
% % Calculates figure positions on an 8.5 x 11 inch paper
%     % Adjusts for default MATLAB figure size (6.5 x 4 inches)
%     % Adds extra spacing if labels are present (second_spacing)
%     % Constants
%     if rows > 3
%         paper_height = 8;  % inches
%     else
%         paper_height = 4.5;
%     end
% 
% %     spacing = 0.5;      % inches between figures
% 
%     % Calculate available width and height after spacing
%     available_width = 8.5 - (cols + 1) * spacing -0.7; % - 0.7 because of margins
%     available_height = 11 - (rows + 1) * spacing -0.5; % - 0.5 because of margins
% 
%     % Determine the figure size (square)
%     figure_size = min(available_width / cols, available_height / rows);
% 
%     % Initialize positions array
%     positions = zeros(rows * cols, 4); % [x, y, width, height]
% 
%     % Calculate positions for each figure
%     index = 1;
%     for r = 1:rows
%         for c = 1:cols
%             if spacing < 0.5
%                 x = spacing + (c - 1) * (figure_size + spacing)+ 0.3; %+ 0.1 in case y labels get cut out
%             else
%                 x = spacing + (c - 1) * (figure_size + spacing)+ 0.2; %+ 0.1 in case y labels get cut out
%             end
%             if ~isempty(second_spacing) && c > 1
%                 x = x + (c - 1) * second_spacing; % Add extra spacing for labels
%             end
%             y = paper_height - (spacing + r * figure_size + (r - 1) * spacing);
% 
%             positions(index, :) = [x, y, figure_size, figure_size];
%             index = index + 1;
%         end
%     end
% end
