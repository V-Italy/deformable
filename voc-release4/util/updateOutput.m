function updateOutput(outDir1, reference)

load (reference);

outputFiles=dir([outDir1,'/image*.mat']);
nFiles = length(outputFiles);

for i = 1:nFiles
    outputName = fullfile(outDir1, outputFiles(i).name);
    load(outputName);
    save(outputName, 'dets', 'boxes', 'pyra', 'score');
end