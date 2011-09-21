function pruneCluster(outDir,detAllName)

if true
    if exist(detAllName)
        load(detAllName);
        % normalize weight to [minw,maxw]
        minw = 0.1;
        maxw = 0.9;
        w = detBoxes(:,5);
        nw = (w-min(w))/(max(w)-min(w))*(maxw-minw)+minw;
        detBoxes(:,end+1) = nw;
        
        nClusters = length(clustMembsCell_n);
        p = size(detRGBHist,2);
        pb = size(detBoxes,2);
        clustMembsCell = cell(nClusters,1);
        % build the gaussian model for each cluster
        for iCluster = 1:nClusters
            n = length(clustMembsCell_n{iCluster});
            if n == 0
                continue;
            end
            
            feas = zeros(n,p);
            pos = zeros(n,pb);
            for i = 1:n
                k = clustMembsCell_n{iCluster}(i);
                feas(i,:) = detRGBHist(k,:);
                pos(i,:) = detBoxes(k,:);
            end
            % sort according to frame number
            [~,ind] = sort(pos(:,6));
            pos = pos(ind,:);
            feas = feas(ind,:);
            MU = mean(feas);
            
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
            
            s(1:2) = pos(1,1:2)+pos(1,3:4)/2;
            s(3:4) = pos(1,3:4);
            s(5:6) = randn(2,1);
            prob_p = pos(1,8);
            for k = 2:n
                % update state
                sn = A*s';
                bp = sn(1:4)';
                % compute probability
                bc(1:2) = pos(k,1:2)+pos(k,3:4)/2;
                bc(3:4) = pos(k,3:4);
                prob_c = pos(k,8);
                prob_b = mvnpdf((bc-bp)./bp,[0,0,1,1],R);
                prob_t = 1/(exp((pos(k,6)-pos(k-1,6))/5-1));
                rho = sum(sqrt(MU.*feas(k,:)));
                prob_l = 1/(sqrt(2*pi)*sigma)*exp((rho - 1)/(2*sigma^2));
                prob_a = prob_p*prob_b*prob_t*prob_l*prob_c;
                if prob_a > 1e-4
                    clustMembsCell(iCluster) = {[clustMembsCell{iCluster},clustMembsCell_n{iCluster}(k)]};
                end
                % update state
                s(1:2) = pos(k,1:2)+pos(k,3:4)/2;
                s(3:4) = pos(k,3:4);
                s(5:6) = randn(2,1);
                prob_p = prob_c;
            end
        end
        save(detAllName, 'clustMembsCell','-append');
    %else
        load(detAllName);
        allImsName = fullfile(outDir, 'all_clustered2.jpg');
        delete(allImsName);
        nRemain = 0;
        count = 0;
        ns = [];
        for i = 1:length(clustMembsCell)
            if length(clustMembsCell{i}) >= 3
                nRemain = nRemain + length(clustMembsCell{i});
                ns = [ns; length(clustMembsCell{i})];
                count = count + 1;
                clustMembsCell2(count) = {clustMembsCell{i}};
            end
        end
        if isempty(ns)
            return;
        end
        
        [~,ind] = sort(ns,'descend');
        clustMembsCell2 = clustMembsCell2(ind);
        save(detAllName, 'clustMembsCell2','-append');
        col = ceil(sqrt(nRemain));
        count = 0;
        n_size = 20;
        row = 0;
        for i = 1:length(clustMembsCell2)
            ni = length(clustMembsCell2{i});
            rowi = ceil(ni/col);
            row = row + rowi;
            count_j = 0;
            for j = clustMembsCell2{i}
                count_j = count_j + 1;
                count = count + 1;
                ims(:,:,:,count) = imresize(detIms{j},[n_size n_size]);
            end
            for k = count_j:col*rowi-1
                count = count + 1;
                ims(:,:,:,count) = zeros(n_size,n_size,3);
            end
        end
        montage(ims,'Size',[row,col]);
        y = 0;
        color = makeColorwheel;
        nClasses = length(clustMembsCell2);
        Nc = floor(length(color)/nClasses);
        for i = 1:nClasses
            ni = length(clustMembsCell2{i});
            row = ceil(ni/col);
            w = n_size*col;
            h = n_size*row;
            rectangle('Position', [0, y, w, h], 'EdgeColor', color((i-1)*Nc+1,:),'LineWidth',2);
            text(0+n_size/5,y+n_size/2,num2str(i),'BackgroundColor',color((i-1)*Nc+1,:));
            y = y + h;
        end
        print('-dpng', allImsName);
        close
    end
end