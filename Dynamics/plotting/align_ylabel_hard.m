function align_ylabel_hard(ax, xnorm)
% Put y-label at a fixed normalized X position for a given axis.
% xnorm is typically between -0.25 and -0.05.
    if nargin < 2
        xnorm = -0.18;   % tweak this number by eye once
    end
    ax.YLabel.Units = 'normalized';
    pos = ax.YLabel.Position;   % [x y z] in normalized units
    pos(1) = xnorm;             % fixed left-right position
    pos(2) = 0.5;               % vertically centered
    ax.YLabel.Position = pos;
end