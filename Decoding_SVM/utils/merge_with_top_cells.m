function [acc, shuff_acc] = merge_with_top_cells(acc, acc_top, shuff_acc, shuff_acc_top)
    acc = concatenate_accuracies(acc, acc_top);
    shuff_acc = concatenate_accuracies(shuff_acc, shuff_acc_top);
end
