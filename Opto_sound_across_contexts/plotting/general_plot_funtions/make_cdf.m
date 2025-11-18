function [cdf,p1] = make_cdf(data,x1);
n1 = hist(data,x1);
p1 = n1./sum(n1);
cdf = cumsum(p1);