function ax = equalSubplotsFromFigure(fig, nRows, nCols, varargin)
% equalSubplotsFromFigure  Create a grid of equally sized axes
% that fill (most of) the given figure.
%
%   ax = equalSubplotsFromFigure(fig, nRows, nCols)
%   ax = equalSubplotsFromFigure(fig, nRows, nCols, 'Name', value, ...)
%
% Inputs
%   fig    : figure handle
%   nRows  : number of rows
%   nCols  : number of columns
%
% Name–value options (all in *normalized* units, 0–1)
%   'Left'   : left margin   (default 0.16)
%   'Right'  : right margin  (default 0.06)
%   'Top'    : top margin    (default 0.06)
%   'Bottom' : bottom margin (default 0.12)
%   'HGap'   : horizontal gap between axes (default 0.03)
%   'VGap'   : vertical gap between axes   (default 0.03)
%
% Output
%   ax : nRows-by-nCols array of axes handles

    p = inputParser;
    addParameter(p, 'Left',   0.3); %.25
    addParameter(p, 'Right',  0.15);
    addParameter(p, 'Top',    0.06);
    addParameter(p, 'Bottom', 0.25);
    addParameter(p, 'HGap',   0.06);
    addParameter(p, 'VGap',   0.06);
    parse(p, varargin{:});
    opt = p.Results;

    % total normalized width/height available for axes
    totalW = 1 - opt.Left - opt.Right;
    totalH = 1 - opt.Top  - opt.Bottom;

    % size of each axis
    axW = (totalW - (nCols-1)*opt.HGap) / nCols;
    axH = (totalH - (nRows-1)*opt.VGap) / nRows;

    if axW <= 0 || axH <= 0
        error('equalSubplotsFromFigure:BadLayout', ...
              'Margins/gaps are too large; axis width/height <= 0.');
    end

    ax = gobjects(nRows, nCols);

    for r = 1:nRows
        for c = 1:nCols
            x = opt.Left + (c-1)*(axW + opt.HGap);
            % rows counted from top; Position y is from bottom
            y = opt.Bottom + (nRows-r)*(axH + opt.VGap);

            ax(r,c) = axes('Parent', fig, ...
                           'Units', 'normalized', ...
                           'ActivePositionProperty', 'position', ...
                           'Position', [x y axW axH]);
%             % Lock OuterPosition to this same rectangle
%             ax(r,c).OuterPosition = [x y axW axH];
        end
    end
end
