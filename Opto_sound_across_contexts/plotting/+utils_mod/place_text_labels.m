function place_text_labels(labels, colors, y_offset_base, fontSize,varargin)
    % Get current axis limits
    x_range = xlim;
    y_range = ylim;
    % Calculate base text position
    if size(varargin,2)>1 %adjust x offset independent of y
        x_offset_base = varargin{2};
    else
        x_offset_base = y_offset_base;
    end
    
    text_x = x_range(2) - x_offset_base * diff(x_range);
    text_y = y_range(1) + y_offset_base * diff(y_range);
    % Default font size if not provided
    if nargin < 4 || isempty(fontSize)
        fontSize = 12;
    end

    % Default location
    location = 'bottomright';
    if ~isempty(varargin)
        location = lower(varargin{1});
    end

    % Calculate base text position depending on location
    switch location
        case 'bottomright'
            text_x = x_range(2) - x_offset_base * diff(x_range);
            text_y = y_range(1) + y_offset_base * diff(y_range);
            y_direction = -1;
        case 'bottomleft'
            text_x = x_range(1) + x_offset_base * diff(x_range);
            text_y = y_range(1) + y_offset_base * diff(y_range);
            y_direction = -1;
        case 'topright'
            text_x = x_range(2) - x_offset_base * diff(x_range);
            text_y = y_range(2) - y_offset_base * diff(y_range);
            y_direction = 1;
        case 'topleft'
            text_x = x_range(1) + x_offset_base * diff(x_range);
            text_y = y_range(2) - y_offset_base * diff(y_range);
            y_direction = 1;
        otherwise
            error('Invalid location option. Choose from: bottomright, bottomleft, topright, topleft.');
    end
%     % Ensure labels and colors match
%     if length(labels) ~= size(colors,1)
%         error('Labels and colors must have the same length');
%     end
    % Auto-calculate evenly spaced y-offsets
    num_labels = length(labels);
    y_offsets = linspace(0, 0.2 * (num_labels - 1), num_labels); % Adjusted scaling
    % Place text labels
    for i = 1:num_labels
        text(text_x, text_y - y_offsets(i) * diff(y_range), labels{i}, ...
             'Color', colors(i,:), 'FontSize', fontSize);
        if size(varargin,2)>2
            text(text_x, text_y - y_offsets(i) * diff(y_range), labels{i}, ...
             'Color', colors(i,:), 'FontSize', fontSize,'BackgroundColor', 'w');   % white background);
        end
    end
end