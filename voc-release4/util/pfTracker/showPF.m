function showPF(pf, im, i)

showBB(im, pf.Smean(:,i)'*pf.H',i,[],'b');
centerX = pf.Smean(1,:)+pf.Smean(5,:)/2;
centerY = pf.Smean(3,:)+pf.Smean(6,:)/2;
plot(centerX,centerY, 'b', 'linewidth', 2);
pCenterX = pf.S(1,:)+pf.S(5,:)/2;
pCenterY = pf.S(3,:)+pf.S(6,:)/2;
plot(pCenterX, pCenterY, 'g+');
title(['Image ', num2str(i)]);