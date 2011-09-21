function showResults(videoDir, detAllName, step, startFrame, endFrame)

% Read the video directory, which contains the frames of the video
if ~isdir(videoDir)
    error([videoDir, ' does not exist!']);
end
imageExt = 'jpg';
imageNames = dir([videoDir, '/*.', imageExt]);
nFrames = length(imageNames);
if nFrames == 0
    disp([videoDir, ' does not contain image with format of ', imageExt]);
    exit(0);
end

% check parameters
if nargin == 2
    step = 1;
    startFrame = 1;
    endFrame = nFrames;
elseif nargin == 3
    startFrame = 1;
    endFrame = nFrames;
elseif nargin == 4
    endFrame = nFrames;
else
    % with full parameters
end

if exist(detAllName, 'file')
    load(detAllName, 'detBoxes', 'clusterMembersCellEnough');
end

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
        [imH, imW, imC] = size(im);
        
        ims = repmat(im,[2,2]);
        
        ind = find(detBoxes(:,5)==k);
        boxes = [detBoxes(ind,1:2),detBoxes(ind,1:2)+detBoxes(ind,3:4)];
        
        
end