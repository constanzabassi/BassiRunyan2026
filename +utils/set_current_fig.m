%% set current figure
function set_current_fig(varargin)
set(gca,'FontName','Arial');
if nargin > 0
    set(gca,'FontSize',varargin{1,1});
else
    set(gca,'FontSize',7);
end
set(gcf,'Color','w')
set(gca,'FontName','Arial')
%set(gca,'Color','k'b)
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'})
axis square
movegui(gcf,'center')