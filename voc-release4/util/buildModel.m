function buildModel(outDir, detAllName)

if exist(detAllName, 'file')
    load(detAllName, 'clusterMembersCellFinal', 'detIms', 'detBoxes', 'detRGBHist');
    if ~exist('clusterMembersCellFinal','var')
        return
    end
    
    % build model for each cluster
    nClusters = length(clusterMembersCellFinal);
    models = cell(nClusters,1);
    for i = 1:nClusters
        % find the median size of all the patches in the cluster
        iMembers = length(clusterMembersCellFinal{i});
        size = [];
        for j = 1:iMembers
            k = clusterMembersCellFinal{i}(j);
            size = [size; detBoxes(k,3:4)];
        end
        msize = ceil(median(size));
        sumIm = 0;
        sumHist = 0;
        for j = 1:iMembers
            k = clusterMembersCellFinal{i}(j);
            detIm = detIms{k};
            detIm = im2double(imresize(detIm, msize));
            sumIm = sumIm + detIm;
            detHist = detRGBHist(k,:);
            sumHist = sumHist + detHist;
        end
        model.repIm = detIms{clusterMembersCellFinal{i}(1)};
        model.meanIm = sumIm/iMembers;
        model.hist = sumHist/iMembers;
        models(i) = {model};
        
    end
    save(detAllName,'model','-append');
    
    plot = true;
    if plot
        modelName = fullfile(outDir, 'all_model.jpg');
        nClusters=min(5,nClusters); % only show top 5
        for i = 1:nClusters
            subplot(nClusters,3,(i-1)*3+1);
            imshow(models{i}.repIm,[]);
            subplot(nClusters,3,(i-1)*3+2);
            imshow(models{i}.meanIm,[]);
            subplot(nClusters,3,(i-1)*3+3);
            bar(models{i}.hist);
        end
        print('-dpng', modelName);
        close
    end
end