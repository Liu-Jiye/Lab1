function result = run_ga(seed,options)
%RUN_GA Real-coded GA using the supplied course GA Toolbox operators.
% ranking -> SUS -> extended intermediate recombination -> BGA mutation.
% Feasibility-first survivor ordering and objective-free segment repair.
if nargin<2, options=struct(); end
if ~isfield(options,'population'), options.population=200; end
if ~isfield(options,'budget'), options.budget=50000; end
N=options.population; budget=options.budget;
assert(mod(budget,N)==0,'Budget must be divisible by population size.');
for name={'ranking','sus','recint','mutbga'}
    assert(~isempty(which(name{1})),'Missing external GA Toolbox operator: %s',name{1});
end
rng(seed,'twister'); started=tic;
X=0.1+4.9*rand(N,5);
[F,~,~,V,feas]=evaluate_population(X);
first=find(feas,1); if isempty(first), first=Inf; end
history=Inf(budget/N,1); firstGen=0;
if any(feas), history(1)=min(F(feas,1)); firstGen=1; end
field=[0.1*ones(1,5);5*ones(1,5)];
for generation=2:budget/N
    % Convert lexicographic feasibility/objective ordering to rank costs.
    [~,order]=sortrows([~feas,V,F(:,1)],[1 2 3]);
    cost=zeros(N,1); cost(order)=(1:N).';
    parentIndices=sus(ranking(cost,[1.8 0]),N); parents=X(parentIndices,:);
    children=recint(parents,1);
    % recint ignores its crossover argument: explicitly apply probability.
    skip=rand(N,1)>0.9; children(skip,:)=parents(skip,:);
    shrink=max(0.002,(1-(generation-1)/(budget/N))^2);
    children=mutbga(children,field,[0.2,shrink]);
    % A feasible anchor is obtained only from candidates already evaluated.
    if any(feas)
        feasibleX=X(feas,:);
        pf=feas(parentIndices);
        anchors=parents;
        anchors(~pf,:)=feasibleX(randi(size(feasibleX,1),sum(~pf),1),:);
        children=repair_segment(children,anchors);
    end
    [newF,~,~,newV,newFeas]=evaluate_population(children);
    if isinf(first) && any(newFeas)
        first=(generation-1)*N+find(newFeas,1); firstGen=generation;
    end
    % Elitist (mu+lambda) selection, keeping all population rows evaluated.
    allX=[X;children]; allF=[F;newF]; allV=[V;newV]; allFeas=[feas;newFeas];
    [~,order]=sortrows([~allFeas,allV,allF(:,1)],[1 2 3]);
    order=order(1:N); X=allX(order,:); F=allF(order,:); V=allV(order); feas=allFeas(order);
    if any(feas), history(generation)=min(F(feas,1)); end
end
[~,idx]=min(F(:,1)+1e6*(~feas));
[finalF,finalC,finalS,~,finalFeasible]=evaluate_population(X(idx,:));
result=struct('seed',seed,'power',X(idx,:),'objective',finalF(1), ...
    'constraints',finalC,'sinr',finalS,'feasible',finalFeasible, ...
    'history',history,'evaluationHistory',(N:N:budget).', ...
    'firstFeasibleEvaluations',first,'firstFeasibleGeneration',firstGen, ...
    'evaluations',budget,'options',options,'seconds',toc(started), ...
    'toolboxOperators',struct('ranking',which('ranking'),'sus',which('sus'), ...
    'recint',which('recint'),'mutbga',which('mutbga'),'rep',which('rep')));
end
