function pf = initPF(im, bb, feature)
%%%%%%%%%%%%%%%%% State Definition %%%%%%%%%%%%%
%
%    S_k = A_k S_{k-1} + N(0, R_k)
%    S_k = (x_k, y_k, w_k, h_k, vx_k, vy_k)

if nargin < 3
    feature = 'rgb2';
end;
if nargin < 2
    error('Useage: initPF(im, bb, [feature])');
end;

%%% Configuration parameters %%%
d = 6; % [cx, cy, w, h, vx, vy]
N = 100; % Number of particles

%%% Initialize the target for tracking %%%
nBins = 50;
angle = 180;
Ls = 2;
nBit = 4;
sBin = 8;
oBin = 9;
nH = 128;
nW = 64;
nFold = 4;
[imH, imW, c] = size(im);
roi = imcrop(im, bb);
[roiH, roiW, c] = size(roi);
switch feature
    case 'rgb1'
        disp('Initialize particle filter tracker with rgb1 feature...');
        cellH = fix(roiH/2^(Ls-1));
        cellW = fix(roiW/2^(Ls-1));
        for xx = 1:cellW:roiW-cellW+1
            for yy=1:cellH:roiH-cellH+1
                cell = roi(yy:yy+cellH-1, xx:xx+cellW-1, :);
                Q = [Q,rgbHist(cell,nBins)];
            end;
        end;
        if sum(Q)~=0
            Q = Q/sum(Q);
        end;
        sigma = 0.1;
    case 'rgb2'
        disp('Initialize particle filter tracker with rgb2 feature...');
        Qc = bitshift(reshape(roi, [], 3), nBit-8);
        kernel = buildKernel(roiW, roiH, 'e');
        Q = ktHistcRgb_c(Qc, kernel.K, nBit)/kernel.sumK;
        Q = Q(:);
        sigma = 0.1;
    case 'hog'
        disp('Initialize particle filter tracker with hog feature...');
        roi_gray = im2double(rgb2gray(roi));
        roi_gray = imresize(roi_gray, [nH, nW]);
        Q = hog(roi_gray,sBin,oBin);
        s=size(Q); s(3)=s(3)/nFold; w0=Q; Q=zeros(s);
        for o=0:nFold-1, Q=Q+w0(:,:,(1:s(3))+o*s(3)); end;
        Q = Q(:)/sum(Q(:))+eps;
        sigma = 0.1;        
end;

% Generate the particle structures
Smean = [bb(1:2)'+bb(3:4)'/2; bb(3:4)'; 0; 0];

%%% Transition matrix %%%
% Transition matrix for the continous-time system.
F = [0 0 0 0 1 0;
     0 0 0 0 0 1;
     0 0 0 0 0 0;
     0 0 0 0 0 3;
     0 0 0 0 0 0;
     0 0 0 0 0 0];
dt = 1; % Stepsize
A = expm(F*dt);

% State Covariance
R = diag([25 25 10 10 1 1]);
C = chol(R)';

% Measurement model.
H = [1 0 0 0 0 0;
     0 1 0 0 0 0;
     0 0 1 0 0 0;
     0 0 0 1 0 0];

% Initial particles
R1 = 2*R;
C1 = chol(R1)';
S = repmat(Smean, 1, N) + C1*randn(d , N); % state
% S = regState(S,imW,imH);

w = ones(1,N)/N;

% Output
pf.d = d;
pf.N = N;
pf.Smean = Smean;
pf.S = S;
pf.A = A;
pf.C = C;
pf.H = H;
pf.sigma = sigma;
pf.Q = Q;
pf.nBins = nBins;
pf.angle = angle;
pf.Ls = Ls;
pf.nBit = nBit;
pf.sBin = sBin;
pf.oBin = oBin;
pf.nH = nH;
pf.nW = nW;
pf.nFold = nFold;
pf.feature = feature;
pf.template = Q;
pf.imW = imW;
pf.imH = imH;
pf.w = w;