function [bb, pf] = pfTracker(im, pf)

%%%%%%%%%%%%%%%%% State Definition %%%%%%%%%%%%%
%    S_k = A_k S_{k-1} + N(0,R_k)
%    S_k = (x_k , y_k , , H_k^x , H_k^y , v_k^x, v_k^y)

if nargin < 2
    error('Useage: pfTracker(im, pf)');
end;
if isempty(pf)
    bb = zeros(4,1);
    return;
end;

% pfPixVals = zeros(size(im,1), size(im,2));
%%% Prediction %%%
pf.S = pf.A*pf.S + pf.C*randn(pf.d, pf.N);
pf.S = regStat(pf.S, pf.imW, pf.imH);
% if isempty(pf.S)
%     bb = zeros(1,4);
%     return;
% end;
bb = s2bb(pf.S, pf.imW, pf.imH);
w = pf.w;

%%% Color likelihood %%%
rho_py_q = zeros(1, pf.N);
switch pf.feature
    case 'rgb1'
        disp('Particle filter tracker with rgb1 feature...');
        for i=1:pf.N
            roi = imcrop(im, bb(:,i));
            [roiH, roiW, c] = size(roi);
            if ndims(roi) ~= 3 || roiH<2^pf.Ls || roiW<2^pf.Ls
                r = zeros(size(pf.Q));
            else
                cellH = fix(roiH/2^(pf.Ls-1));
                cellW = fix(roiW/2^(pf.Ls-1));
                r = [];
                for xx = 1:cellW:roiW-cellW+1
                    for yy=1:cellH:roiH-cellH+1
                        cell = roi(yy:yy+cellH-1, xx:xx+cellW-1,:);
                        r = [r, rgbHist(cell, pf.nBins)];
                    end;
                end;
                if sum(r)~=0
                    r = r/sum(r);
                end;
            end;
            rho_py_q(i) = sum(sqrt(r.*pf.Q));
        end;
    case 'rgb2'
        disp('Particle filter tracker with rgb2 feature...');
        for i=1:pf.N
            roi = imcrop(im, bb(:,i));
            [roiH, roiW, c] = size(roi);
            if ndims(roi) ~= 3 || roiH<2^pf.Ls || roiW<2^pf.Ls
                q = zeros(size(pf.Q));
            else
                Qc = bitshift(reshape(roi, [], 3), pf.nBit-8);
                kernel = buildKernel(roiW, roiH, 'e');
                q = ktHistcRgb_c(Qc, kernel.K, pf.nBit)/kernel.sumK;
                q = q(:);
            end;
            rho_py_q(i) = sum(sqrt(q.*pf.Q));
        end;
    case 'hog'
        disp('Particle filter tracker with hog feature...');
        for i=1:pf.N
            roi = imcrop(im, bb(:,i));
            [roiH, roiW, c] = size(roi);
            if ndims(roi) ~= 3 || roiH<2^pf.Ls || roiW<2^pf.Ls
                h = zeros(size(pf.Q));
            else
                roi_gray = im2double(rgb2gray(roi));
                roi_gray = imresize(roi_gray, [pf.nH, pf.nW]);
                h = hog(roi_gray, pf.sBin, pf.oBin);
                s=size(h); s(3)=s(3)/pf.nFold; w0=h; h=zeros(s);
                for o=0:pf.nFold-1, h=h+w0(:,:,(1:s(3))+o*s(3)); end;
                h = h(:)/sum(h(:))+eps;
            end;
            rho_py_q(i) = sum(sqrt(h.*pf.Q));
        end;
end;
likelihood_color = 1/(sqrt(2*pi)*pf.sigma)*exp((rho_py_q - 1)/(2*pf.sigma^2));
w = w.*likelihood_color;
w = w/sum(w);
% w(isnan(w)) = 1/pf.N;

%%% MMSE estimate %%%
[maxW, maxIdx] = max(w);
pf.Smean = pf.S(:,maxIdx);

%%% Particles resampling ? if N_eff < N_threshold %%%
% N_eff = 1/sum(w.^2);
% if N_eff < pf.N
    % Always resampling
    ind = resample(w);
    pf.S = pf.S(:, ind);
%     pf.w = w(ind);
%     pf.w = pf.w/sum(pf.w);
    pf.w = ones(1,pf.N)/pf.N;
% end
pf.Smean  = sum(repmat(pf.w, pf.d, 1).*pf.S, 2);
% if any(isnan(pf.Smean))
%     pf.Smean = zeros(pf.d, 1);
% end;
bb = s2bb(pf.Smean, pf.imW, pf.imH);
bb = fix(bb');

