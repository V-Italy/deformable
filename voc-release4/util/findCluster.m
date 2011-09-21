function findCluster(videoDir, outDir, model, detAllName, step, startFrame, endFrame)

if ~exist(detAllName,'file')
    % Step1: Compute the RGB histogram for all the detection
    detScores = []; detBoxes = [];
    detIms = {}; detRGBHist = [];
    cbin = 16; cl = 2; % parameters for rgb histogram
    for k = startFrame : step : endFrame
        if k>endFrame
            break;
        end
        % read in the image
        inImageName = fullfile(videoDir, ['image', num2str(k), '.jpg']);
        if ~exist(inImageName, 'file')
            disp([inImageName, ' does not exist! Break loop...']);
            break;
        end
        im = imread(inImageName);
        
        % read in the detection results
        detName = fullfile(outDir, ['image', num2str(k), '.mat']);
        if ~exist(detName, 'file')
            disp([detName, ' does not exist! Break loop...']);
            break;
        end
        load(detName);
        
        % read the bounding box
        if ~isempty(boxes)
            bbox = bboxpred_get(model.bboxpred, dets, reduceboxes(model, boxes));
            bbox = clipboxes(im, bbox);
            top = nms(bbox, 0.5);
            for i = 1:length(top)
                p = top(i);
                detScores = [detScores; bbox(p,5)];
                % bb is of format [left top width height]
                bb(1:2) = bbox(p,1:2);
                bb(3:4) = bbox(p,3:4) - bbox(p,1:2);
                detBoxes = [detBoxes; [bb, k, p]];
                detIm = imcrop(im, bb); % crop the image with the bb
                detIms = [detIms, {detIm}];
                rgb_f = rgbHist(detIm,cbin,cl);
                detRGBHist = [detRGBHist; rgb_f];
            end
        end
    end
    save(detAllName, 'detScores','detBoxes','detIms','detRGBHist','-v7.3');

    % do meanshift on the detected patch
    bandwidth = 0.045;
    [clusterCenter,point2cluster,clusterMembersCell] = MeanShiftCluster(detRGBHist',bandwidth);
    
    % only keep the clusters which have sufficient members
    clusterMembersCellEnough = keepCluster(clusterMembersCell, 10);
    
    % save the clustering result
    save(detAllName,'clusterCenter','point2cluster','clusterMembersCell',...
        'clusterMembersCellEnough','-append');
    
    % draw the montage for all the cluster
    montageX(clusterMembersCellEnough, detIms);
    allImsName = fullfile(outDir, 'all_clustered.jpg');
    if exist(allImsName, 'file')
        delete(allImsName);
    end
    print('-dpng', allImsName);
    close
end