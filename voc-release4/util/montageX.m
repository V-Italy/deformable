function montageX(cluster, detIms)

% count the number in the clusters
nClusters = length(cluster);
N = 0;
for i = 1:nClusters
    N = N + length(cluster{i});
end

% show the montage of the remaining clusters
nCol = ceil(sqrt(N)); nRow = 0;
mSize = 20; % size of the image when displayed in montage
countImg = 0;
nClusters = length(cluster);
% get all the patches
for i = 1:nClusters
    iMembers = length(cluster{i});
    iRow = ceil(iMembers/nCol);
    nRow = nRow + iRow;
    % get all the detection patches from cluster i
    for j = cluster{i}
        countImg = countImg + 1;
        ims(:,:,:,countImg) = imresize(detIms{j},[mSize mSize]);
    end
    % pad the cluster i to make sure it has nRow*nCol patches
    for k = iMembers+1:nCol*iRow
        countImg = countImg + 1;
        ims(:,:,:,countImg) = zeros(mSize,mSize,3);
    end
end
montage(ims,'Size',[nRow,nCol]);

% draw the cluster info
color = makeColorwheel; % generate the color
cStep = floor(length(color)/nClusters);
x = 0; y = 0; % position of the rectangle for each cluster
for i = 1:nClusters
    iMembers = length(cluster{i});
    iRow = ceil(iMembers/nCol);
    w = mSize*nCol;
    h = mSize*iRow;
    c = color((i-1)*cStep+1,:);
    rectangle('Position', [0, y, w, h], 'EdgeColor', c, 'LineWidth', 2);
    text(0+mSize/5, y+mSize/2, num2str(i), 'BackgroundColor', c);
    y = y + h;
end
