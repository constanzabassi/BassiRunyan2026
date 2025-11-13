function plot_info = default_plot_info(all_model_outputs)
    plot_info.colors_active_passive = [0.16, 0.40, 0.24 %green
                               0.30 0.58 0.40 
                               0.13, 0.24, 0.51%blue
                               0.282, 0.239, 0.545
                            0.17 0.35 0.8  
                            0.50, 0.06, 0.10
                            0.82 0.04 0.04
                            0.482, 0.408, 0.933];

    plot_info.colors = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0.282, 0.239, 0.545 %dark purple
                            0.16, 0.40, 0.24]; %dark green

    plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0.282, 0.239, 0.545 %dark purple
                            0.16, 0.40, 0.24]; %dark green


    plot_info.minmax = [0.45,.9];
    plot_info.xlims = [1,32]; %[1,length(all_model_outputs{1,1}{1}.binns)];

end
