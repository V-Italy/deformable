function detectObj(videoDir, outDir, category, step, startFrame, endFrame)

% Parse th parameters
if nargin < 3 || nargin > 6
	error('Usage: proc_video(videoDir, outDir, category, step=1, startFrame=1, endFrame=1000)');
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

% Check the output directory
if ~isdir(outDir)
	mkdir(outDir);
end

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

% Load the model of the given category
if ~exist(category)
	error([category, ' does not exist!']);
end
load(category);

% Test all the frames
for k = startFrame : step : endFrame
	if k>endFrame
		break;
	end
	inImageName = fullfile(videoDir, ['image', num2str(k), '.jpg']);
	im = imread(inImageName);
	% detect objects
	tic
	load(category);
	[dets, boxes, info, score] = imgdetect(im, model, -1);
	toc
	% show the image
	outName = fullfile(outDir, ['image', num2str(k), '.mat']);
	save(outName, 'dets', 'boxes', 'score');
end
