function audit = verify_results(root)
%VERIFY_RESULTS Recompute saved objectives, feasibility, nondomination and HV.
if nargin<1, root=fileparts(fileparts(mfilename('fullpath'))); end
evidence=jsondecode(fileread(fullfile(root,'validation','course_toolbox_runtime.json')));
assert(evidence.passed);
out=fullfile(root,'results'); a=load(fullfile(out,'ga_results.mat'));
assert(numel(a.gaRuns)==20 && all(a.feasible));
for k=1:20
    r=a.gaRuns{k};
    for name={'ranking','sus','recint','mutbga','rep'}
        assert(strcmp(r.toolboxOperators.(name{1}),evidence.operators.(name{1}).path));
    end
    [F,C,S,~,ok]=evaluate_population(r.power);
    assert(ok && max(abs(F(1)-r.objective))<1e-10 && all(S>=2));
    assert(r.evaluations==50000 && numel(r.history)==250);
    h=r.history(isfinite(r.history)); assert(all(diff(h)<=1e-10));
    assert(abs(h(end)-r.objective)<1e-10);
    assert(r.firstFeasibleEvaluations<=r.evaluations);
    assert(max(C)<=0);
end
assert(abs(a.gaStats.median-17.0014)<0.10);
m=load(fullfile(out,'moead_results.mat')); p=load(fullfile(out,'pareto_typical.mat'));
for k=1:3
    r=m.moeadRuns{k}; [F,C,S,~,~]=evaluate_population(r.paretoSet);
    assert(all(C<=0,'all') && all(r.paretoSet>=0.1 & r.paretoSet<=5,'all') && all(S>=2,'all') && max(abs(F-r.paretoFront),[],'all')<1e-10);
    [~,Fnd]=nondominated2(r.paretoSet,r.paretoFront); assert(isequal(Fnd,r.paretoFront));
    assert(abs(hypervolume2(F)-r.hv)<1e-10 && all(diff(r.hvHistory)>=-1e-10));
    assert(r.evaluations==201*(1000+1));
end
assert(abs(p.typicalHV-median(m.hv))<1e-12);
assert(isequal(p.paretoSet,m.moeadRuns{p.typicalIndex}.paretoSet));
audit=struct('passed',true,'courseToolboxVerified',true,'gaRuns',20,'moeadRuns',3,'strictFeasible',true, ...
    'medianGAError',abs(a.gaStats.median-17.0014),'typicalHV',p.typicalHV, ...
    'typicalParetoRows',size(p.paretoSet,1),'matlabVersion',version);
fid=fopen(fullfile(root,'validation','results_audit.json'),'w'); fprintf(fid,'%s',jsonencode(audit,PrettyPrint=true)); fclose(fid);
fprintf('Saved-results audit PASSED. GA median error %.10f; HV %.10f\n',audit.medianGAError,audit.typicalHV);
end
