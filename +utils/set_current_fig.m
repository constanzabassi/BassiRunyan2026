%% set current figure
function set_current_fig(varargin)
set(gca,'FontName','Arial');
if nargin > 0
    set(gca,'FontSize',varargin{1,1});
else
    set(gca,'FontSize',7);
end
ax = gca;
ax.XLabel.FontSize = ax.FontSize;
ax.YLabel.FontSize = ax.FontSize;
set(gcf,'Color','w')
set(gca,'FontName','Arial')
%set(gca,'Color','k'b)
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'})
if nargin < 1
axis square
end
movegui(gcf,'center')