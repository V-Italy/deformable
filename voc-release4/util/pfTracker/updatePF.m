function curPF = updatePF(curIm, curBB, oldPF, weight)

if curBB(3) ==0 || curBB(4) == 0
    curPF = oldPF;
    curPF.Q = curPF.template;
    return;
end;
curPF = initPF(curIm, curBB, oldPF.feature);
curPF.w = oldPF.w;
curPF.S = oldPF.S;
curPF.Smean = oldPF.Smean;
curPF.template = oldPF.template; % preserve the template

alpha = 1-weight;
curPF.Q = alpha*curPF.template+(1-alpha)*curPF.Q;