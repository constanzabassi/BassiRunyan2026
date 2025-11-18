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
% function place_text_labels(labels, colors, y_offset_base, varargin)
%     % PLACE_TEXT_LABELS places text labels on a plot with flexible positioning and styling.
%     %
%     % Required:
%     %   labels         - Cell array of label strings
%     %   colors         - Nx3 matrix of RGB color values
%     %   y_offset_base  - Base offset (0-1) for positioning horizontally (x-axis)
%     %
%     % Optional (via varargin, name-value pairs):
%     %   'FontSize'     - Font size for text (default: 12)
%     %   'UseTop'       - true to anchor from top (y_range(2)), false from bottom (default)
%     %   'YLim'         - Override for y-axis limits (e.g., ylim2)
%     %   'YOffset'      - Additional vertical offset (0-1), applied after anchoring (default: 0)
% 
%     % Default options
%     fontSize = 12;
%     useTop = false;
%     y_range_override = [];
%     y_offset_extra = 0;
% 
%     % Parse varargin
%     for i = 1:2:length(varargin)
%         switch lower(varargin{i})
%             case 'fontsize'
%                 fontSize = varargin{i+1};
%             case 'usetop'
%                 useTop = varargin{i+1};
%             case 'ylim'
%                 y_range_override = varargin{i+1};
%             case 'yoffset'
%                 y_offset_extra = varargin{i+1};
%             otherwise
%                 error('Unknown parameter name: %s', varargin{i});
%         end
%     end
% 
%     % Get axis limits
%     x_range = xlim;
%     y_range = isempty(y_range_override) * ylim ;
%     if ~isempty(y_range_override)
%         y_range = y_range_override;
%     end
% 
%     % X position for text (right side of plot with offset)
%     text_x = x_range(2) - y_offset_base * diff(x_range);
% 
%     % Y starting position with optional anchor and extra offset
%     if useTop
%         text_y = y_range(2) - y_offset_base * diff(y_range);
%         direction = -1; % move downward
%         if ~isempty(y_offset_extra)
%             text_y = y_range(2) - y_offset_extra * diff(y_range);
%         end
%     else
%         text_y = y_range(1) + y_offset_base * diff(y_range);
%         direction = 1; % move upward
%         if ~isempty(y_offset_extra)
%             text_y = y_range(1) + y_offset_extra * diff(y_range);
%         end
%     end
% 
%     % Determine y spacing between labels
%     num_labels = length(labels);
%     y_offsets = linspace(0, 0.2 * (num_labels - 1), num_labels);
% 
%     % Place each label
%     for i = 1:num_labels
%         ypos = text_y + direction * y_offsets(i) * diff(y_range);
%         text(text_x, ypos, labels{i}, 'Color', colors(i,:), 'FontSize', fontSize);
%     end
% end
% 
% 
% % function place_text_labels(labels, colors, y_offset_base, fontSize, y2_offset_base, ylim2)
% %     % Get current axis limits
% %     x_range = xlim;
% %     if nargin < 6
% %         y_range = ylim;
% %     else
% %         y_range = ylim2;
% %     end
% %     % Calculate base text position
% %     text_x = x_range(2) - y_offset_base * diff(x_range);
% %     if nargin < 5
% %         text_y = y_range(1) + y_offset_base * diff(y_range);
% %     else
% %         text_y = y_range(1) + y2_offset_base * diff(y_range);
% %     end
% %     % Default font size if not provided
% %     if nargin < 4
% %         fontSize = 12;
% %     end
% % %     % Ensure labels and colors match
% % %     if length(labels) ~= size(colors,1)
% % %         error('Labels and colors must have the same length');
% % %     end
% %     % Auto-calculate evenly spaced y-offsets
% %     num_labels = length(labels);
% %     y_offsets = linspace(0, 0.2 * (num_labels - 1), num_labels); % Adjusted scaling
% %     % Place text labels
% %     for i = 1:num_labels
% %         text(text_x, text_y - y_offsets(i) * diff(y_range), labels{i}, ...
% %              'Color', colors(i,:), 'FontSize', fontSize);
% %     end
% % end