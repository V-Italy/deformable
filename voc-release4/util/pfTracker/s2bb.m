function bbs = s2bb(S, imW, imH)
% s2bb can get the bb from S
% S = [cx; cy; w; h; vx; vy];
% bb = [lx; ly; w; h];

[nSDims, nS] = size(S);
bbs = zeros(4,nS);
bbs(1,:) = min(imW, max(1, S(1,:)-S(3,:)/2));
bbs(2,:) = min(imH, max(1, S(2,:)-S(4,:)/2));
bbs(3,:) = max(1, min(imW-bbs(1,:)+1, S(3,:)));
bbs(4,:) = max(1, min(imH-bbs(2,:)+1, S(4,:)));
bbs = round(bbs);