function hv = hypervolume2(F,reference)
%HYPERVOLUME2 Exact union area for two MINIMIZATION objectives.
if nargin<2, reference=[26 0]; end
F=F(all(isfinite(F),2) & all(F<=reference,2),:);
[~,F]=nondominated2(zeros(size(F,1),0),F);
if isempty(F), hv=0; return; end
hv=sum((reference(1)-F(:,1)).*([reference(2);F(1:end-1,2)]-F(:,2)));
end
