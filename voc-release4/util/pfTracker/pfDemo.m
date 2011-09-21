% This is the demo of how to use pfTracker, change some parameter to run
% the demo.
% Notice: To run this demo successfully, it needs some other functions,
% such as readFrame, showBB, ml_findBox1b2, etc. Those auxiliary functions
% can be found in ../utils. Make sure you include them in the searchable
% path of Matlab

clear all
close all
trackerName = 'pf';

%%% Change the video name %%%
sourceType = 'AVI';
videoName = fullfile('F:\EnsembleTrackers','ShortTrecvidTrackingSecuences/single/videos/avi/train1.avi');
% iamgeDir = fullfile('F:\EnsembleTrackers','ShortTrecvidTrackingSecuences/single/frames/train1');
switch sourceType
    case 'IMAGES'
        [pathstr, prefix, ext] = fileparts(imageDir);
        source.dir = imageDir;
        source.imageNames = dir([source.dir, '/*.jpg']);
    case 'AVI'
        [pathstr, prefix, ext] = fileparts(videoName);
        source.dir = videoName;
        source.vid = mmreader(videoName);
    case 'USB'
        source.cam = initWebcam;
end;
source.type = sourceType;

%%% You can change the first frame number %%%
bbFirstFrame = 1;
firstIm = readFrame(source, bbFirstFrame);
source.size = size(firstIm);
nFrames = source.vid.NumberOfFrames;
bbs = zeros(nFrames,4);

% Initialize the pfTracker
annotationFileName = fullfile('F:\EnsembleTrackers','ShortTrecvidTrackingSecuences/single/annotations/mat/train1.mat');
load(annotationFileName);
if ~exist('bbGT','var')
    disp('Select the people to track');
    bbFirst = selectObj(firstIm);
else
    bbFirst = bbGT(bbFirstFrame,:);
end;
pf = initPF(firstIm, bbFirst, 'rgb2');

% Save the result
% [pathstr, name] = fileparts(videoName);
% outVideoName = fullfile(pathstr, [name, '_', trackerName ,'.avi']);
% if verLessThan('matlab', '7.11.0')
%     % Matlab R2010a or lower version
%     outObj = avifile(outVideoName,'compression','Cinepak');
% else
%     % Matlab R2010b or higher version
%     outObj = VideoWriter(outVideoName);
%     open(outObj);
% end;

% Initialize figure
hF = figure(1000); clf;
set(hF, 'MenuBar', 'none', 'Color', 'k', 'NumberTitle', 'off');

for i=bbFirstFrame+1:nFrames
    tic
    disp([prefix,':',num2str(i),'/',num2str(nFrames)]);
    
    % track
    curIm = read(source.vid, i);
    [bbs(i,:), pf] = pfTracker(curIm, pf);
    
    % Show result
    set(hF, 'Name', ['Tracking Results: ', num2str(i), '/', num2str(nFrames)]);
    hF = showBB(hF, curIm, bbs, i, {trackerName}, 'bt');
    if ~ishandle(hF)
        break;
    end;
    
    % Output
    F = getframe(hF);
%     if verLessThan('matlab', '7.11.0')
%         % Matlab 2010a or lower version
%         outObj = addframe(outObj,F);
%     else
%         % Matlab 2010b or lower version
%         writeVideo(outObj,F);
%     end;
    
    toc
end;
% close(outObj);