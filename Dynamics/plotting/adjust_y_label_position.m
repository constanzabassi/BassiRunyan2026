function adjust_y_label_position(subplot_reference,subplots_to_change,offset)
%subplot_reference - subplot ID that will be used for the x position across
%all subplots
%subplots_to_change - subplot IDs that will now have the updated x position
%offset - use if the y label has more than a single row 

if isempty(offset)
    offset = 10;
end
fig = gcf; 
ax_ce = findobj(fig, 'Type', 'axes', 'Tag', sprintf('heat_ax_%d', subplot_reference));
yposition = ax_ce.YLabel.Position(1) -offset;%-10 bc it is 2 rows and position is based on the middle?
for ce = subplots_to_change
    ax_ce = findobj(fig, 'Type', 'axes', 'Tag', sprintf('heat_ax_%d', ce));
    if ~isempty(ax_ce)
        current_pos = ax_ce.YLabel.Position;
        ax_ce.YLabel.Position = [yposition, current_pos(2), current_pos(3)];
    end
end