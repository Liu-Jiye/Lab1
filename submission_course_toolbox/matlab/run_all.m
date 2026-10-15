function summary = run_all(toolboxPath,resume)
%RUN_ALL Reproduce all assessed runs, plots and machine-readable evidence.
% Usage: addpath('submission_course_toolbox/matlab'); run_all('/path/to/course/toolbox');
% Unmodified external toolbox operators are deliberately NOT distributed.
if nargin<2, resume=false; end
root=fileparts(fileparts(mfilename('fullpath')));
assert(nargin>0 && ~isempty(toolboxPath),'Provide the supplied course toolbox path.');
addpath(toolboxPath,'-begin');
toolboxEvidence=verify_course_toolbox(toolboxPath,root);
addpath(fullfile(root,'matlab'));
out=fullfile(root,'results'); if ~exist(out,'dir'), mkdir(out); end
validation=validate_implementation();
save(fullfile(root,'validation','implementation_tests.mat'),'validation','-v7');
gaSeeds=(11001:11020).'; gaOptions=struct('population',200,'budget',50000);
gaRuns=cell(20,1);
for k=1:20
    cached=fullfile(out,sprintf('ga_run_%02d.mat',k));
    if resume && exist(cached,'file')
        old=load(cached,'r'); gaRuns{k}=old.r;
        assert(old.r.seed==gaSeeds(k) && isequal(old.r.options,gaOptions));
        assert(strcmp(old.r.toolboxOperators.ranking,which('ranking')),'Cached run used another toolbox.');
    else
        gaRuns{k}=run_ga(gaSeeds(k),gaOptions);
    end
    r=gaRuns{k};
    save(fullfile(out,sprintf('ga_run_%02d.mat',k)),'r','-v7');
    fprintf('GA %02d seed %d f %.10f maxC %.3g evals %d first %g\n',k,r.seed,r.objective,max(r.constraints),r.evaluations,r.firstFeasibleEvaluations);
end
objectives=cellfun(@(r)r.objective,gaRuns); feasible=cellfun(@(r)r.feasible,gaRuns);
firstFeasible=cellfun(@(r)r.firstFeasibleEvaluations,gaRuns);
histories=cell2mat(cellfun(@(r)r.history,gaRuns,'UniformOutput',false).');
evaluationHistory=gaRuns{1}.evaluationHistory;
v=objectives(feasible);
gaStats=struct('best',min(v),'worst',max(v),'mean',mean(v),'median',median(v), ...
    'std',std(v,0),'feasibleRuns',sum(feasible),'totalRuns',20, ...
    'medianFirstFeasibleEvaluations',median(firstFeasible));
save(fullfile(out,'ga_results.mat'),'gaRuns','gaSeeds','gaOptions','histories','evaluationHistory','objectives','feasible','firstFeasible','gaStats','-v7');
write_csv(fullfile(out,'ga_runs.csv'),'run,seed,objective,feasible,first_feasible_evaluations',[(1:20).',gaSeeds,objectives,feasible,firstFeasible]);
write_csv(fullfile(out,'ga_convergence.csv'),'', [evaluationHistory,histories]);
moeadSeeds=(21001:21003).'; moeadOptions=struct('population',201,'generations',1000,'neighborhood',20);
moeadRuns=cell(3,1);
for k=1:3
    moeadRuns{k}=run_moead(moeadSeeds(k),moeadOptions);
    r=moeadRuns{k}; save(fullfile(out,sprintf('moead_run_%02d.mat',k)),'r','-v7');
    fprintf('MOEAD %d HV %.10f points %d evals %d\n',k,r.hv,size(r.paretoFront,1),r.evaluations);
end
hv=cellfun(@(r)r.hv,moeadRuns); [~,order]=sort(hv); typicalIndex=order(2);
paretoSet=moeadRuns{typicalIndex}.paretoSet; paretoFront=moeadRuns{typicalIndex}.paretoFront;
referencePoint=[26 0]; typicalSeed=moeadSeeds(typicalIndex); typicalHV=hv(typicalIndex);
save(fullfile(out,'pareto_typical.mat'),'paretoSet','paretoFront','referencePoint','typicalIndex','typicalSeed','typicalHV','-v7');
save(fullfile(out,'moead_results.mat'),'moeadRuns','moeadSeeds','moeadOptions','hv','typicalIndex','-v7');
counts=cellfun(@(r)size(r.paretoFront,1),moeadRuns);
write_csv(fullfile(out,'moead_runs.csv'),'run,seed,hv,pareto_count',[(1:3).',moeadSeeds,hv,counts]);
write_csv(fullfile(out,'pareto_set.csv'),'',paretoSet); write_csv(fullfile(out,'pareto_front.csv'),'',paretoFront);
summary=struct('ga',gaStats,'moeadHV',hv,'typicalIndex',typicalIndex,'typicalSeed',typicalSeed, ...
    'typicalHV',typicalHV,'paretoCount',size(paretoFront,1),'matlabVersion',version, ...
    'gaOptions',gaOptions,'moeadOptions',moeadOptions,'courseToolboxVerified',toolboxEvidence.passed,'timestamp',char(datetime('now','Format','yyyy-MM-dd HH:mm:ss')));
fid=fopen(fullfile(out,'summary.json'),'w'); fprintf(fid,'%s',jsonencode(summary,PrettyPrint=true)); fclose(fid);
verify_results(root);
end

function write_csv(path,header,data)
% Plain numeric CSV export, independent of shadowed table classes.
fid=fopen(path,'w');
if ~isempty(header), fprintf(fid,'%s\n',header); end
fmt=[repmat('%.17g,',1,size(data,2)-1),'%.17g\n'];
fprintf(fid,fmt,data.'); fclose(fid);
end
