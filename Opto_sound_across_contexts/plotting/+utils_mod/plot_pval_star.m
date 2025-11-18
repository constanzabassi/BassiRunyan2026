function plot_pval_star(x_val, y_val, p, xline_vars,y_val_line_diff,varargin)
%%% assumes distance between three is x_seq = [-0.2, 0, 0.2];

% Add significance symbols based on p-value
if p < 0.0001
    sig_symbol = '****';
elseif p < 0.001
    sig_symbol = '***';
elseif p < 0.01
    sig_symbol = '**';
elseif p < 0.05
    sig_symbol = '*';
else
    sig_symbol = '';
end

% Determine the height of text based on the maximum value of the boxplot
yMax = y_val;%max(max(whiskerplot([data1; data2])));
text_height = yMax;

% Plot significance symbol
if ~isempty(sig_symbol)
    if nargin > 5 %include this for adding specific color
        text(x_val+mean([xline_vars(1),xline_vars(2)]), text_height, sig_symbol,'HorizontalAlignment', 'center', 'Color', varargin{1},'FontSize',8);
        line([x_val+xline_vars(1), x_val+xline_vars(2)], [y_val-y_val_line_diff, y_val-y_val_line_diff], 'Color', varargin{1}, 'LineWidth', 0.5);
    else
        text(x_val+mean([xline_vars(1),xline_vars(2)]), text_height, sig_symbol,'HorizontalAlignment', 'center', 'Color', 'k','FontSize',8);
        line([x_val+xline_vars(1), x_val+xline_vars(2)], [y_val-y_val_line_diff, y_val-y_val_line_diff], 'Color', 'k', 'LineWidth', 0.5);
    end
end

% hold off;


