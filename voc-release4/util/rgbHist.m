function [imHoC, imBins] = rgbHist(im, nBins, cL)

[imH, imW, ~] = size(im);
imHoC = [];
for l = 1:cL
    cellH = fix(imH/2^(l-1));
    cellW = fix(imW/2^(l-1));
    for xx = 1:cellW:imW-cellW+1
        for yy=1:cellH:imH-cellH+1
            cell = imcrop(im, [xx yy cellW cellH]);
            [r, bins] = rgbHistX(cell, nBins);
            if l == 1
                imBins = bins;
            end
            imHoC = [imHoC, r'];
        end;
    end;
end
if sum(imHoC)~=0
    imHoC = imHoC/sum(imHoC);
end;

function [imHoC, imBins] = rgbHistX(im, nBins)

[~, ~, c] = size(im);
if nargin < 2
    error('You have to provide the edges, it could be the number of edges or explicitly the edges.');
end;
edges = linspace(0-eps, 255+eps, nBins+1);
% im = im2double(im);

imHoC = zeros(c*nBins,1);
imBins = zeros(size(im));
for i=1:c
    imC = im(:,:,i);
    [imHC, imBins(:,:,i)] = histc(imC, edges);
    imHC(nBins,:) = imHC(nBins,:)+imHC(nBins+1,:);
    imHC(nBins+1,:) = [];
    %     imBins(:,:,i)
    imBins(:,:,i) = imBins(:,:,i)+(i-1)*nBins;
    imBins(imBins==i*nBins+1) = i*nBins;
    imHoC((i-1)*nBins+1:i*nBins) = sum(imHC,2);
end;