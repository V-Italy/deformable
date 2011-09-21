function kernel = buildKernel(w, h, type)

switch type
    case 'e'
        w = round(w/2)*2;
        xs = linspace(-1,1,w);
        h = round(h/2)*2;
        ys = linspace(-1,1,h);
        [ys,xs] = ndgrid(ys,xs);
        xs=xs(:); ys=ys(:);
        xMag = ys.*ys + xs.*xs;
        xMag(xMag>1) = 1;
        K = 2/pi * (1-xMag);
        sumK=sum(K);
    case 'n'
        w = round(w/2)*2;
        xs = linspace(-1,1,w);
        h = round(h/2)*2;
        ys = linspace(-1,1,h);
        K = ones(w*h, 1);
        sumK = w*h;
    otherwise
        error('Unknown kernel');
end;
kernel = struct('K', K, 'sumK', sumK, 'xs', xs, 'ys', ys, 'w', w, 'h', h);