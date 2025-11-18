function bootstrapResults = handle_separate_BootstrapResults(pVals_left,pVals_right,side,nNeurons)
    pVals_max = zeros(1, nNeurons);
    for n = 1:nNeurons
        if strcmp(side{n}, 'left')
            pVals_max(n) = pVals_left(n);
        else
            pVals_max(n) = pVals_right(n);
        end
    end
    bootstrapResults.left = pVals_left;
    bootstrapResults.right = pVals_right;
    bootstrapResults.max = pVals_max;
    bootstrapResults.pVals = pVals_max;