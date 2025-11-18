function heatmap_nan_datasets(data_to_plot,save_string,save_dir)
positions = utils.calculateFigurePositions(1, 5, .5, []);

figure(100); clf;
hold on

colormap gray
imagesc(data_to_plot)
movegui(gcf,'center');

% Overlay red for NaNs
[rows, cols] = find(isnan(data_to_plot));
for i = 1:length(rows)
    rectangle('Position',[cols(i)-0.5, rows(i)-0.5, 1, 1], ...
              'EdgeColor','none','FaceColor','r');
end
ylabel('Bins');
xlabel('Dataset ID');

set(gca, 'FontSize', 8, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;

% Save results
if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    exportgraphics(figure(100),strcat('heatmap_nan_datasets',save_string,'.pdf'), 'ContentType', 'vector');

end
