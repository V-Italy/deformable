function snms(outDir, detAllName)
% perform spatial non maximum surpression, an extension of the non maximum
% surpression

if exist(detAllName, 'file')
    load(detAllName, 'detBoxes', 'detRGBHist', 'detIms', 'detScores',...
        'clusterMembersCellEnough');
    
    nClusters = length(clusterMembersCellEnough);
    clusterMembersCellConstrain = cell(nClusters,1);
    p = size(detRGBHist,2);
    pb = size(detBoxes,2);
    % build the gaussian model for each cluster
    for iCluster = 1:nClusters
        iMembers = length(clusterMembersCellEnough{iCluster});
        if iMembers == 0
            continue;
        end
        
        feas = zeros(iMembers,p);
        pos = zeros(iMembers,pb);
        for i = 1:iMembers
            k = clusterMembersCellEnough{iCluster}(i);
            feas(i,:) = detRGBHist(k,:);
            pos(i,:) = detBoxes(k,:);
        end
        % sort according to frame number
        [~,ind] = sort(pos(:,5));
        pos = pos(ind,:);
        feas = feas(ind,:);
        detScores = detScores(ind,:);
        MU = mean(feas);
        SIGMA = cov(feas);
        
        % normalize weight to [minw,maxw]
        minw = 0.1;
        maxw = 0.9;
        w = detScores;
        nw = (w-min(w))/(max(w)-min(w))*(maxw-minw)+minw;
        
        % define the dynamic model
        sigma = 0.1;
        %%% Transition matrix %%%
        % Transition matrix for the continous-time system.
        F = [0 0 0 0 0 0;
            0 0 0 0 0 0;
            0 0 0 0 0 0;
            0 0 0 0 0 0;
            0 0 0 0 0 0;
            0 0 0 0 0 0];
        dt = 1; % Stepsize
        A = expm(F*dt);
        
        % State Covariance
        R = diag([0.1 0.1 0.1 0.1]);
        C = chol(R)';
        
        % define s as the state
        s(1:2) = pos(1,1:2)+pos(1,3:4)/2;
        s(3:4) = pos(1,3:4);
        s(5:6) = randn(2,1);
        pScorePrev = nw(1); % detection score
        for k = 2:iMembers
            % update state
            sn = A*s';
            bbPrev = sn(1:4)';
            % compute probability
            bb(1:2) = pos(k,1:2)+pos(k,3:4)/2;
            bb(3:4) = pos(k,3:4);
            pScore = nw(k);
            xChange = (bb(1)-bbPrev(1))/bbPrev(3);
            yChange = (bb(2)-bbPrev(2))/bbPrev(4);
            wChange = (bb(3)-bbPrev(3))/max(bb(3),bbPrev(3));
            hChange = (bb(4)-bbPrev(4))/max(bb(4),bbPrev(4));
            change = [xChange, yChange, wChange, hChange];
            pDistance = mvnpdf(change,[0,0,0,0],R);
            % pTime = 1/(exp((pos(k,5)-pos(k-1,5))/step-1));
            rho = sum(sqrt(MU.*feas(k,:)));
            pLike = 1/(sqrt(2*pi)*sigma)*exp((rho - 1)/(2*sigma^2));
            pAll = log(pScorePrev*pScore*pDistance*pLike);
            if pAll > -5
                clusterMembersCellConstrain(iCluster) = {[clusterMembersCellConstrain{iCluster},clusterMembersCellEnough{iCluster}(k)]};
            end
            % update state
            s(1:2) = pos(k,1:2)+pos(k,3:4)/2;
            s(3:4) = pos(k,3:4);
            s(5:6) = randn(2,1);
            pScorePrev = pScore;
        end
    end
    
    save(detAllName, 'clusterMembersCellConstrain','-append');
    
    % only keep the clusters which have sufficient members after snms
    clusterMembersCellFinal = keepCluster(clusterMembersCellConstrain, 10);
    save(detAllName, 'clusterMembersCellFinal','-append');
    
    % generate the montage
    montageX(clusterMembersCellFinal, detIms);
    allImsName = fullfile(outDir, 'all_clustered2.jpg');
    if exist(allImsName, 'file')
        delete(allImsName);
    end
    print('-dpng', allImsName);
    close
end