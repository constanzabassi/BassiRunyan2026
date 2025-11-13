function concat_acc = concatenate_accuracies (acc1, acc2)
%concatenate accuracies vertically (for instance regular vs top neurons)
n_datasets = size(acc1,2);

concat_acc = cell(1, n_datasets);

for dataset = 1:n_datasets
    a1 = acc1{1, dataset};
    a2 = acc2{1, dataset};

    % If acc2 is 2D, expand it to 3D
    if ndims(a2) == 2
        a2 = reshape(a2, size(a2,1), size(a2,2), 1);
    end

    % Concatenate along 3rd dimension
    concat_acc{1, dataset} = cat(3, a1, a2);
end