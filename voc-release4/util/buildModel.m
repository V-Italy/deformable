function buildModel(outDir, detAllName)

if exist(detAllName, 'file')
    load(detAllName);
    if ~exist('clustMembsCell2','var')
        return
    end
    
    model = cell(length(clustMembsCell2),3);
    for i = 1:length(clustMembsCell2)
        size = [];
        for j = 1:length(clustMembsCell2{i})
            k = clustMembsCell2{i}(j);
            size = [size; detBoxes(k,3:4) - detBoxes(k,1:2)];
        end
        msize = ceil(median(size));
        sumIm = 0;
        sumHist = 0;
        for j = 1:length(clustMembsCell2{i})
            k = clustMembsCell2{i}(j);
            detIm = detIms{k};
            detIm = im2double(imresize(detIm, msize));
            sumIm = sumIm + detIm;
            detHist = detRGBHist(k,:);
            sumHist = sumHist + detHist;
        end
        model(i,1) = {detIms{clustMembsCell2{i}(1)}};
        model(i,2) = {sumIm/length(clustMembsCell2{i})};
        model(i,3) = {sumHist/length(clustMembsCell2{i})};
        
    end
    save(detAllName,'model','-append');
    
    plot = true;
    if plot
        modelName = fullfile(outDir, 'all_model.jpg');
        nClusters = length(clustMembsCell2);
        for i = 1:nClusters
            subplot(nClusters,2,(i-1)*2+1);
            imshow(model{i,1},[]);
            subplot(nClusters,2,(i-1)*2+2);
            bar(model{i,3});
        end
        print('-dpng', modelName);
        close
    end
end