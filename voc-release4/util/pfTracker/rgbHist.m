function [imHoC, imBins] = rgbHist(im, nBins)

% im = im2double(im);
[~, ~, c] = size(im);
if nargin < 2
    error('You have to provide the edges, it could be the number of edges or explicitly the edges.');
end;

edges = linspace(0-eps, 255+eps, nBins+1);
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
imHoC = imHoC'/sum(imHoC);