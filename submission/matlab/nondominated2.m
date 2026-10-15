function [X,F] = nondominated2(X,F)
%NONDOMINATED2 Exact 2-D minimization archive; remove duplicates/dominated rows.
if isempty(F), return; end
[F,order] = sortrows(F,[1 2]); X=X(order,:);
[F,uniqueRows] = unique(F,'rows','stable'); X=X(uniqueRows,:);
keep=false(size(F,1),1); best=Inf;
for k=1:size(F,1)
    if F(k,2)<best
        keep(k)=true; best=F(k,2);
    end
end
X=X(keep,:); F=F(keep,:);
end
