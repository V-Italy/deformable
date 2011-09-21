function clusterPruned = keepCluster(cluster, k)

% only keep the clusters which have at least k members
nClusters = length(cluster);
nRemain = 0;
members = [];
clusterPruned = {};
for i = 1:nClusters
    iMembers = length(cluster{i});
    if iMembers > k
        nRemain = nRemain + iMembers;
        members = [members; iMembers];
        clusterPruned = [clusterPruned, cluster(i)];
    end
end
if isempty(members)
    return;
end
[~,ind] = sort(members,'descend');
clusterPruned = clusterPruned(ind);
