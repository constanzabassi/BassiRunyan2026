function cb = add_skinny_colorbar(ax, fontsize, width_frac, lateral_sum, varargin)
%ADD_SKINNY_COLORBAR Adds a skinny, right-positioned colorbar to an axis.
%
%   cb = ADD_SKINNY_COLORBAR(ax, fontsize)
%
%   INPUTS:
%       ax        - Handle to the target axes.
%       fontsize  - (optional) Font size for the colorbar labels (default = 6)
%
%   OUTPUT:
%       cb        - Handle to the created colorbar.
%
%   This function attaches a colorbar to the specified axes on the
%   east (right) side, makes it thinner, and adjusts its position
%   slightly to look balanced.

    if nargin < 2
        fontsize = 6;
    end

    % Create colorbar
    cb = colorbar(ax, 'eastoutside');
    cb.FontSize = fontsize;

    % Make colorbar skinny
    ax_pos = get(ax,'Position');
    cb_pos = cb.Position;
    if isempty(width_frac)
        cb_pos(3) = 0.0167; %default width
    else
        cb_pos(3) = cb_pos(3) * width_frac;  % narrow width (0.3)
    end

    % Move colorbar closer and slightly resize vertically
%     cb_pos(1) = cb_pos(1) + lateral_sum; %0.1
    cb_pos(1) = ax_pos(1) + ax_pos(3) + lateral_sum;
    if nargin > 4
        cb_pos(2) = cb_pos(2) + varargin{1,1}; %0.05
        cb_pos(4) = cb_pos(4) - varargin{1,1};
    end

    % Apply new position
    cb.Position = cb_pos;

end
