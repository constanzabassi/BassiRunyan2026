function add_vertical_line_reward(ax, frames, width, color)
% Add vertical highlight bands covering full pixel columns of a heatmap.
%
% ax     – axis handle
% frames – vector of frame indices (1-based)
% width  – width in pixels (default = 1)
% color  – RGB or name (default = [1 1 1] white)
    if nargin < 3 || isempty(width)
        width = 1;
    end
    if nargin < 4 || isempty(color)
        color = [1 1 1]; % white
    end
    hold(ax,'on');
    yl = ylim(ax);
    for f = frames
        % Rectangle spanning full y-range and "width" columns
        x0 = f - 0.5;        % left edge of pixel column
        w  = width;          % how many pixel columns wide
        rectangle(ax, ...
            'Position', [x0, yl(1), w, diff(yl)], ...
            'FaceColor', color, ...
            'EdgeColor', 'none', ...
            'Clipping', 'off');
    end
end