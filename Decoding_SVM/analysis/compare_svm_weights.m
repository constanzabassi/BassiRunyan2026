function [betas] = compare_svm_weights(output)
%INPUT: outcome{num_iterations,mouse,cell_id}.mdl{1,time_bin} cell_id==4 is all cells!
%OUTPUT: beta{num_iterations,mouse,bins}

for m = 1:size(output,2)
    for bin = 1:length(output{1,1,4}.mdl)
        for it = 1:size(output,1)
            betas{it,m,bin} = output{it,m,4}.mdl{1,bin}.Beta;
        end
    end
end