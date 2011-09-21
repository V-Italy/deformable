function [dets, boxes, info, pyraInfo, score] = imgdetect(input, model, thresh, bbox, overlap)

% Wrapper that computes detections in the input image.
%
% input    input image
% model    object model
% thresh   detection score threshold
% bbox     ground truth bounding box
% overlap  overlap requirement

% we assume color images
input = color(input);

% get the feature pyramid
pyra = featpyramid(input, model);

if nargin < 4
  bbox = [];
end

if nargin < 5
  overlap = 0;
end

[dets, boxes, info, pyraInfo, score] = gdetect(pyra, model, thresh, bbox, overlap);
