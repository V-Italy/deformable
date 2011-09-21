function findCluster(videoDir, outDir, model, detAllName, step, startFrame, endFrame)

if ~exist(detAllName,'file')
    % Step1: Compute the RGB histogram for all the detection
    detScores = [];
    detBoxes = [];
    detRGBHist = [];
    detIms = {};
    bin = 16;
    pbin = 8; angle = 180; L = 2;
    count = 0;
    for k = startFrame : step : endFrame
        if k>endFrame
            break;
        end
        % read in the image
        inImageName = fullfile(videoDir, ['image', num2str(k), '.jpg']);
        if ~exist(inImageName, 'file')
            break;
        end
        im = imread(inImageName);
        
        % read in the detection results
        detName = fullfile(outDir, ['image', num2str(k), '.mat']);
        if ~exist(detName, 'file')
            break;
        end
        load(detName);
        
        % read the bounding box
        if ~isempty(boxes)
            bbox = bboxpred_get(model.bboxpred, dets, reduceboxes(model, boxes));
            bbox = clipboxes(im, bbox);
            top = nms(bbox, 0.5);
            for i = 1:length(top)
                detBoxes = [detBoxes; [bbox(top(i),:),k,top(i)]];
                bb(1:2) = bbox(top(i),1:2);
                bb(3:4) = bbox(top(i),3:4) - bbox(top(i),1:2);
                detIm = imcrop(im, bb);
                count = count + 1;
                detIms(count) = {detIm};
                rgb_f = rgbHist(detIm,bin);
                %                 phog_f = anna_phog(detIm,pbin,angle,L);
                phog_f = [];
                detRGBHist = [detRGBHist; [rgb_f,phog_f]];
            end
        end
    end
    save(detAllName, 'detBoxes','detIms','detRGBHist','-v7.3');
else
    load(detAllName);
    bandwidth = 0.045;
    [clustCent,point2cluster,clustMembsCell] = MeanShiftCluster(detRGBHist',bandwidth);
    nRemain = 0;
    count = 0;
    ns = [];
    for i = 1:length(clustMembsCell)
        if length(clustMembsCell{i}) > 10
            nRemain = nRemain + length(clustMembsCell{i});
            ns = [ns; length(clustMembsCell{i})];
            count = count + 1;
            clustMembsCell_n(count) = {clustMembsCell{i}};
        end
    end
    [~,ind] = sort(ns,'descend');
    clustMembsCell_n = clustMembsCell_n(ind);
    save(detAllName,'clustCent','point2cluster','clustMembsCell_n','-append');
    col = ceil(sqrt(nRemain));
    count = 0;
    n_size = 20;
    row = 0;
    for i = 1:length(clustMembsCell_n)
        ni = length(clustMembsCell_n{i});
        rowi = ceil(ni/col);
        row = row + rowi;
        count_j = 0;
        for j = clustMembsCell_n{i}
            count_j = count_j + 1;
            count = count + 1;
            ims(:,:,:,count) = imresize(detIms{j},[n_size n_size]);
        end
        for k = count_j:col*rowi-1
            count = count + 1;
            ims(:,:,:,count) = zeros(n_size,n_size,3);
        end
    end
    montage(ims,'Size',[row,col]);
    y = 0;
    color = makeColorwheel;
    nClasses = length(clustMembsCell_n);
    Nc = floor(length(color)/nClasses);
    for i = 1:nClasses
        ni = length(clustMembsCell_n{i});
        row = ceil(ni/col);
        w = n_size*col;
        h = n_size*row;
        rectangle('Position', [0, y, w, h], 'EdgeColor', color((i-1)*Nc+1,:),'LineWidth',2);
        text(0+n_size/5,y+n_size/2,num2str(i),'BackgroundColor',color((i-1)*Nc+1,:));
        y = y + h;
    end
    allImsName = fullfile(outDir, 'all_clustered.jpg');
    print('-dpng', allImsName);
    close
end