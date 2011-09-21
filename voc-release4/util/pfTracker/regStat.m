function S = regStat(S,imW,imH)
% Change invalid state
% S = 6*N, N is the number of state. S(:,i) = [cx; cy; w; h; vx; vy]


% Restrict the sampled bounding box within particular region
boardDist = 5;
S(1,:) = max(boardDist, min(imW-boardDist+1, S(1,:)));
S(2,:) = max(boardDist, min(imH-boardDist+1, S(2,:)));
S(3,:) = max(2*boardDist, min(S(3,:), min(2*S(1,:), 2*(imW-S(1,:)+1))));
S(4,:) = max(2*boardDist, min(S(4,:), min(2*S(2,:), 2*(imH-S(2,:)+1))));

% wS = min(S(5,:), min((imW-S(1,:))*2./S(3,:), 2*S(1,:)./S(3,:)));
% hS = min(S(5,:), min((imH-S(2,:))*2./S(4,:), 2*S(2,:)./S(4,:)));
% S(5,:) = min(wS, hS);