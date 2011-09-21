function [dets, boxes, info] = score2bb(scores, model, pyra, thresh)

% find scores above threshold
X = zeros(0, 'int32');
Y = zeros(0, 'int32');
I = zeros(0, 'int32');
L = zeros(0, 'int32');
S = [];
for level = model.interval+1:length(pyra.scales)
  score = scores{level};
  tmpI = find(score > thresh);
  [tmpY, tmpX] = ind2sub(size(score), tmpI);
  X = [X; tmpX];
  Y = [Y; tmpY];
  I = [I; tmpI];
  L = [L; level*ones(length(tmpI), 1)];
  S = [S; score(tmpI)];
end

[ign, ord] = sort(S, 'descend');
% only return the highest scoring example in latent mode
% (the overlap requirement has already been enforced)
if latent && ~isempty(ord)
  ord = ord(1);
end
X = X(ord);
Y = Y(ord);
I = I(ord);
L = L(ord);
S = S(ord);

% compute detection bounding boxes and parse information
[dets, boxes, info] = getdetections(model, pyra.padx, pyra.pady, ...
                                    pyra.scales, X, Y, L, S);

% sanity check overlap requirement
if latent && ~isempty(dets)
  clipdets = dets;
  % clip detection window to image boundary
  clipdets(:,1) = max(clipdets(:,1), 1);
  clipdets(:,2) = max(clipdets(:,2), 1);
  clipdets(:,3) = min(clipdets(:,3), pyra.imsize(2));
  clipdets(:,4) = min(clipdets(:,4), pyra.imsize(1));
  if boxoverlap(clipdets, bbox) < overlap
    error('overlap requirement failed');
  end
end