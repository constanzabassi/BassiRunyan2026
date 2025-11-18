function [p, observeddifference, effectsize] = permutationTest_updatedcb(sample1, sample2, permutations, varargin)
    % parsing input
    p = inputParser;
    addRequired(p, 'sample1', @isnumeric);
    addRequired(p, 'sample2', @isnumeric);
    addRequired(p, 'permutations', @isnumeric);
    addParamValue(p, 'sidedness', 'both', @(x) any(validatestring(x,{'both', 'smaller', 'larger'})));
    addParamValue(p, 'exact' , 0, @isnumeric);
    addParamValue(p, 'plotresult', 0, @isnumeric);
    addParamValue(p, 'showprogress', 0, @isnumeric);
    addParamValue(p, 'paired', 0, @isnumeric); % New parameter for paired test
    parse(p, sample1, sample2, permutations, varargin{:})
    sample1 = p.Results.sample1;
    sample2 = p.Results.sample2;
    permutations = p.Results.permutations;
    sidedness = p.Results.sidedness;
    exact = p.Results.exact;
    plotresult = p.Results.plotresult;
    showprogress = p.Results.showprogress;
    paired = p.Results.paired;
    % enforcing row vectors
    if iscolumn(sample1), sample1 = sample1'; end
    if iscolumn(sample2), sample2 = sample2'; end
    if paired
        if length(sample1) ~= length(sample2)
            error('For paired tests, sample1 and sample2 must have the same length');
        end
        differences = sample1 - sample2;
        observeddifference = mean(differences);
        pooledstd = std(differences);
    else
        allobservations = [sample1, sample2];
        observeddifference = nanmean(sample1) - nanmean(sample2);
        pooledstd = sqrt(  ( (numel(sample1)-1)*std(sample1)^2 + (numel(sample2)-1)*std(sample2)^2 )  /  ( numel(allobservations)-2 )  );
    end
    effectsize = observeddifference / pooledstd;
    % Handle exact test warning
    if ~paired && ~exact && permutations > nchoosek(numel(allobservations), numel(sample1))
        warning(['the number of permutations (%d) is higher than the number of possible combinations (%d);\n' ...
                 'consider running an exact test using the ''exact'' argument'], ...
                 permutations, nchoosek(numel(allobservations), numel(sample1)));
    end
    if showprogress, w = waitbar(0, 'Preparing test...', 'Name', 'permutationTest'); end
    if exact
        % getting all possible combinations
        if paired
            allcombinations = dec2bin(0:2^numel(differences)-1) - '0';
            permutations = size(allcombinations, 1);
        else
            allcombinations = nchoosek(1:numel(allobservations), numel(sample1));
            permutations = size(allcombinations, 1);
        end
    end
    % running test
    randomdifferences = zeros(1, permutations);
    if showprogress, waitbar(0, w, sprintf('Permutation 1 of %d', permutations), 'Name', 'permutationTest'); end
    for n = 1:permutations
        if showprogress && mod(n,showprogress) == 0, waitbar(n/permutations, w, sprintf('Permutation %d of %d', n, permutations)); end
        if paired
            % Paired permutation test: randomly flip the signs of differences
            if exact
                signs = allcombinations(n,:) * 2 - 1;
            else
                signs = randi([0, 1], size(differences)) * 2 - 1;
            end
            randomdifferences(n) = mean(signs .* differences);
        else
            % Unpaired permutation test
            if exact
                permutation = [allcombinations(n,:), setdiff(1:numel(allobservations), allcombinations(n,:))];
            else
                permutation = randperm(length(allobservations));
            end
            % dividing into two samples
            randomSample1 = allobservations(permutation(1:length(sample1)));
            randomSample2 = allobservations(permutation(length(sample1)+1:length(permutation)));
            % saving differences between the two samples
            randomdifferences(n) = nanmean(randomSample1) - nanmean(randomSample2);
        end
    end
    if showprogress, delete(w); end
    % getting probability of finding observed difference from random permutations
    if strcmp(sidedness, 'both')
        p = (length(find(abs(randomdifferences) > abs(observeddifference)))+1) / (permutations+1);
    elseif strcmp(sidedness, 'smaller')
        p = (length(find(randomdifferences < observeddifference))+1) / (permutations+1);
    elseif strcmp(sidedness, 'larger')
        p = (length(find(randomdifferences > observeddifference))+1) / (permutations+1);
    end
    % plotting result
    if plotresult
        figure;
        if verLessThan('matlab', '8.4')
            % MATLAB R2014a and earlier
            hist(randomdifferences, 20);
        else
            % MATLAB R2014b and later
            histogram(randomdifferences, 20);
        end
        hold on;
        xlabel('Random differences');
        ylabel('Count')
        od = plot(observeddifference, 0, '*r', 'DisplayName', sprintf('Observed difference.\nEffect size: %.2f,\np = %f', effectsize, p));
        legend(od);
    end
end