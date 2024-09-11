function [Y] = robust_interp1(x,y,X,method);
% [Y] = robust_interp1(x,y,X,method);
if nargin<4
    method='linear';
end
if sum(isnan(x.*y))|length(x)>length(unique(x))
    % If there're any NaNs in the arguments
    nrange =find(~isnan(x));
    x=x(nrange);
    y=y(nrange);

    nrange = find(~isnan(y));
    x=x(nrange);
    y=y(nrange);

    [x2,I]=unique(x);
    x=x2;
    y=y(I);
    if length(x)>2
        Y = interp1(x,y,X,method);
    else
        Y=NaN*X;
    end
else
    Y = interp1(x,y,X,method);
end
    