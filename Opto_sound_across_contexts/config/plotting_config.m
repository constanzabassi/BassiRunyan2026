function plot_info = plotting_config()
%% set colors and titles
plot_info.behavioral_contexts = {"Active","Passive"}; %,"Spont"};
% plot_info.lineStyles_contexts = [{'-.'},{'--'}, {'-'}];
plot_info.lineStyles_contexts = [{'-'},{'-'}, {'-'}];
plot_info.colors_stimctrl(1,:) = [0.9 0.6 0]; %yellow
plot_info.colors_stimctrl(2,:) = [0.5 0.5 0.5]; %gray

plot_info.colors_celltypes = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04]; % red  

% %active,passive,spont for each cell type
plot_info.colors_celltypes_3contexts = [0.16, 0.40, 0.24 %dark green
                               0.54, 0.82, 0.64 %0.30 0.58 0.40 %light green
                               0.54, 0.82, 0.64 %light green
                               0.13, 0.24, 0.51 %dark blue
                            0.55, 0.65, 0.89 % light blue 0.17 0.35 0.8  %blue
                            0.55, 0.65, 0.89 % light blue 
                            0.50, 0.06, 0.10 %dark red
                            0.92, 0.36, 0.41 % light red 0.82 0.04 0.04
                            0.92, 0.36, 0.41];% light red  
% plot_info.colors_celltypes_3contexts = [
%     % Greens
%     0.16, 0.40, 0.24;  % original dark green
%     0.56, 0.75, 0.52;  % light green (CVD-safe)
%     0.73, 0.88, 0.70;  % lighter green (CVD-safe)
% 
%     % Blues
%     0.13, 0.24, 0.51;  % original dark blue
%     0.38, 0.60, 0.82;  % light blue (CVD-safe)
%     0.66, 0.81, 0.96;  % lighter blue (CVD-safe)
% 
%     % Reds
%     0.50, 0.06, 0.10;  % original dark red
%     0.86, 0.44, 0.58;  % light red (CVD-safe, like rose)
%     0.98, 0.70, 0.78   % lighter red (CVD-safe, pinkish)
% ];



plot_info.colors_celltypes_2contexts = [0.16, 0.40, 0.24 %green
                               0.30 0.58 0.40 
                               0.13, 0.24, 0.51%blue
                            0.17 0.35 0.8  
                            0.50, 0.06, 0.10
                            0.82 0.04 0.04]; % red  

plot_info.colors_celltypes_4contexts = [
    0.16, 0.40, 0.24      % dark green
    0.30, 0.58, 0.40      % mid green
    0.54, 0.82, 0.64      % light green
    0.74, 0.92, 0.80      % lightest green

    0.13, 0.24, 0.51      % dark blue
    0.17, 0.35, 0.80      % mid blue
    0.55, 0.65, 0.89      % light blue
    0.78, 0.84, 0.95      % lightest blue

    0.50, 0.06, 0.10      % dark red
    0.82, 0.04, 0.04      % mid red
    0.92, 0.36, 0.41      % light red
    0.97, 0.68, 0.70      % lightest red
];


plot_info.colors_contexts = [0.99, 0.42, 0 %dark orange
                               0.99, 0.62, 0 %medium
                               1, 0.82, 0.01 %light orange
                            0.13 0.14 0.16  %dark gray
                            0.38, 0.41, 0.44
                            0.55, 0.59, 0.62]; % light gray 

plot_info.colors_contexts_simple = [0,0,0;0.5, 0.5, 0.5]; % light gray 

                            
plot_info.celltype_names = {"Pyr","SOM","PV"};

%for distinguishing functional colors
plot_info.colors_pooled_3contexts = [0.3,0.2,0.6 %purple
                               0.7200,0.6800,0.8400 %
                               0.7200,0.6800,0.8400 %
                               1,0.7,0 %yelloiw
                            1.0000,0.8800,0.6000 % 
                            1.0000,0.8800,0.6000 % 
                            0.3,0.8,1 % cyan
                            0.7200,0.9200,1.0000 % 
                            0.7200,0.9200,1.0000
                            0,0,0 %black
                            0.7,0.7,0.7
                            0.7,0.7,0.7
                            0.2,0,0.6 %purple
                               0.6200,0.5800,0.8400 %
                               0.6200,0.5800,0.8400 ]%];% 
plot_info.pooled_colors = [0.3,0.2,0.6
                            1,0.7,0
                            0.3,0.8,1
                            0.5 0.5 0.5
                            0.2,0,0.5];
plot_info.pooled_names = {'Sound','Photostim','Both','Unmodulated','Sound Negative'};
