function postProcess(videoDir, outDir, category, step, startFrame, endFrame)

% Parse the parameters
if nargin < 3 || nargin > 6
    error('Usage: postProcess(videoDir, outDir, category, step=1, startFrame=1, endFrame=1000)');
end

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

% Load the model of the given category
if ~exist(category)
    error([category, ' does not exist!']);
end
load(category);

% check parameters
if nargin == 3
    step = 1;
    startFrame = 1;
    endFrame = nFrames;
elseif nargin == 4
    startFrame = 1;
    endFrame = nFrames;
elseif nargin == 5
    endFrame = nFrames;
else
    % with full parameters
end

% Step 0: detect the object for the individual frame
if isdir(outDir)
    detectObj(videoDir, outDir, category, step, startFrame, endFrame);
end

detAllName = fullfile(outDir, 'detAll.mat');

% step 1: use mean shift to find the cluster
findCluster(videoDir, outDir, model, detAllName, step, startFrame, endFrame)

% step 2: perform the spatial non maximum surpression to prune the
% background cluster
snms(outDir, detAllName);

% step 3: build model for each remaining cluster
buildModel(outDir,detAllName);

% step 3: tracking detection
% trackDet(videoDir, outDir, detAllName,step, startFrame, endFrame);