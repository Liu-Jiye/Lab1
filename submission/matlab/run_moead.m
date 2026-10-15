function result = run_moead(seed,options)
%RUN_MOEAD MOEA/D-DE with normalized Tchebycheff decomposition.
% Independent random initialization; neighborhoods of adjacent weight vectors;
% DE/rand/1/bin and polynomial mutation; feasibility-first local replacement;
% an exact feasible nondominated external archive retains evaluated candidates.
if nargin<2, options=struct(); end
if ~isfield(options,'population'), options.population=201; end
if ~isfield(options,'generations'), options.generations=800; end
if ~isfield(options,'neighborhood'), options.neighborhood=20; end
N=options.population; T=options.neighborhood; rng(seed,'twister'); started=tic;
W=[linspace(0,1,N).',linspace(1,0,N).'];
[~,B]=sort(abs(W(:,1)-W(:,1).'),2); B=B(:,1:T);
X=0.1+4.9*rand(N,5); [F,~,~,V,feas]=evaluate_population(X,1e-12);
z=min(F,[],1); archiveX=X(feas,:); archiveF=F(feas,:);
[archiveX,archiveF]=nondominated2(archiveX,archiveF);
hvHistory=zeros(options.generations+1,1); hvHistory(1)=hypervolume2(archiveF);
evals=N; first=find(feas,1); if isempty(first), first=Inf; end
% Fixed scales cover comparable changes in power and negative sum-rate.
scale=[8,1.5]; delta=0.9; differentialWeight=0.5; crossoverRate=0.9;
for generation=1:options.generations
    newX=zeros(N,5); newF=zeros(N,2); newFeas=false(N,1);
    for i=randperm(N)
        if rand<delta, pool=B(i,:); else, pool=1:N; end
        r=pool(randperm(numel(pool),3));
        mutant=X(r(1),:)+differentialWeight*(X(r(2),:)-X(r(3),:));
        mask=rand(1,5)<crossoverRate; mask(randi(5))=true;
        child=X(i,:); child(mask)=mutant(mask);
        child=min(5,max(0.1,child));
        child=polynomial_mutation(child,0.2,20);
        if feas(i)
            child=repair_segment(child,X(i,:));
        elseif any(feas)
            candidates=find(feas); child=repair_segment(child,X(candidates(randi(numel(candidates))),:));
        end
        [cf,~,~,cv,ok]=evaluate_population(child,1e-12); evals=evals+1;
        if ok && isinf(first), first=evals; end
        if ok, z=min(z,cf); end
        % Feasible solutions compare scalar subproblem values; infeasible
        % solutions compare total violation. At most two replacements.
        count=0;
        for j=pool(randperm(numel(pool)))
            weight=max(W(j,:),1e-6);
            gChild=max(weight.*abs(cf-z)./scale);
            gOld=max(weight.*abs(F(j,:)-z)./scale);
            better=(ok && ~feas(j)) || (~ok && ~feas(j) && cv<V(j)) || ...
                (ok && feas(j) && gChild<gOld);
            if better
                X(j,:)=child; F(j,:)=cf; V(j)=cv; feas(j)=ok;
                count=count+1; if count>=2, break; end
            end
        end
        newX(i,:)=child; newF(i,:)=cf; newFeas(i)=ok;
    end
    [archiveX,archiveF]=nondominated2([archiveX;newX(newFeas,:)],[archiveF;newF(newFeas,:)]);
    hvHistory(generation+1)=hypervolume2(archiveF);
    if mod(generation,100)==0
        fprintf('MOEAD seed %d generation %d HV %.8f archive %d\n',seed,generation,hvHistory(generation+1),size(archiveF,1));
    end
end
result=struct('seed',seed,'paretoSet',archiveX,'paretoFront',archiveF, ...
    'hv',hypervolume2(archiveF),'hvHistory',hvHistory,'referencePoint',[26 0], ...
    'evaluations',evals,'firstFeasibleEvaluations',first,'options',options, ...
    'weights',W,'neighborhoods',B,'scales',scale,'seconds',toc(started));
end

function x=polynomial_mutation(x,probability,eta)
% Bounded Deb polynomial mutation with per-variable probability 1/d.
for j=1:5
    if rand>=probability, continue; end
    d1=(x(j)-0.1)/4.9; d2=(5-x(j))/4.9; u=rand; exponent=1/(eta+1);
    if u<=0.5
        change=(2*u+(1-2*u)*(1-d1)^(eta+1))^exponent-1;
    else
        change=1-(2*(1-u)+2*(u-0.5)*(1-d2)^(eta+1))^exponent;
    end
    x(j)=min(5,max(0.1,x(j)+4.9*change));
end
end
