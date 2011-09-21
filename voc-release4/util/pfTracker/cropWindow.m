function [Ic,Qc] = cropWindow(I, nBit, center, w, h)
top = center(2)-h/2;
left = center(1)-w/2;
Ic = I(top:top+h-1, left:left+w-1,:);
if(nargout==2)
    Qc = bitshift(reshape(Ic,[],3), nBit-8);
end;