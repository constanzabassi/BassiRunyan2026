function basic_stats = get_basic_stats(data1)
basic_stats.mean = mean(data1,'omitnan');
basic_stats.sd = std(data1,'omitnan');
% basic_stats.ci = paramci(data1);
basic_stats.n = length(data1);
basic_stats.n_nonan = length(data1(~isnan(data1)));
if basic_stats.n_nonan > 1
    basic_stats.sem = basic_stats.sd / sqrt(basic_stats.n_nonan);
else
    basic_stats.sem = nan;
end
if length(data1) > 1 && ~all(isnan(data1))
    [ci,bootstat] = bootci(1000,@(x)[mean(x,'omitnan') std(x,'omitnan')],data1); %ci (:,1) lower and upper bounds of mean, ci (:,2) lower and uppder bounds of standard deviation
    basic_stats.ci = ci;
    basic_stats.bootstat = bootstat;
else
    basic_stats.ci = nan;
    basic_stats.bootstat = nan;
end
