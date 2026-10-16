function validation = validate_implementation()
%VALIDATE_IMPLEMENTATION Independent loop oracle, repair and HV regression tests.
rng(719,'twister'); X=0.1+4.9*rand(37,5);
[F,C,S,~,ok]=evaluate_population(X); G=power_model();
Sref=zeros(37,5);
for row=1:37
    for i=1:5
        denominator=0.5;
        for j=1:5
            if j~=i, denominator=denominator+G(i,j)*X(row,j); end
        end
        Sref(row,i)=G(i,i)*X(row,i)/denominator;
    end
end
assert(isequal(size(F),[37 2]) && isequal(size(C),[37 5]));
assert(isequal(size(power_objective(X)),[37 1]));
assert(max(abs(S-Sref),[],'all')<1e-13);
assert(max(abs(C-(1./Sref-0.5)),[],'all')<1e-13);
assert(max(abs(F(:,1)-sum(X,2)))<1e-13);
[oneC,eq,oneS]=power_constraints(X(1,:));
assert(isempty(eq) && isequal(size(oneC),[1 5]) && isequal(size(oneS),[1 5]));
assert(isequal(size(power_objective(zeros(0,5))),[0 1]));
bad={ones(5,1),ones(2,4),[NaN 1 1 1 1],[Inf 1 1 1 1],zeros(1,5),-ones(1,5)};
for i=1:numel(bad)
    caught=false;
    try
        power_constraints(bad{i});
    catch
        caught=true;
    end
    assert(caught,'Invalid input was accepted.');
end
% Hand-calculated union: [2,-3] gives 24; [4,-5] adds 12 => 36.
assert(abs(hypervolume2([2 -3;4 -5],[10 0])-36)<1e-12);
assert(hypervolume2(zeros(0,2))==0);
assert(abs(hypervolume2([4 -5;2 -3;2 -3;5 -2],[10 0])-36)<1e-12);
assert(hypervolume2([27 -10])==0);
[Xnd,Fnd]=nondominated2((1:5).',[2 -3;4 -5;2 -3;5 -2;3 -2]);
assert(isequal(Fnd,[2 -3;4 -5]) && numel(Xnd)==2);
% A hand-checked feasible TEST FIXTURE, never passed to either algorithm.
parent=[4.4,3.9,3.8,5,3.8]; [~,~,~,~,valid]=evaluate_population(parent); assert(valid);
repaired=repair_segment(0.1+4.9*rand(1000,5),repmat(parent,1000,1));
[~,~,~,~,valid]=evaluate_population(repaired); assert(all(valid));
% Check linear equivalence for random positive inputs.
[~,A,b]=power_model(); linearOK=all(X*A.'<=b.',2);
assert(isequal(linearOK,ok));
validation=struct('passed',true,'loopOracleMaxError',max(abs(S-Sref),[],'all'), ...
    'randomRows',37,'repairRows',1000,'hvHandExample',36, ...
    'matlabVersion',version,'timestamp',char(datetime('now','Format','yyyy-MM-dd HH:mm:ss')));
fprintf('Implementation tests PASSED. Max oracle error %.3g\n',validation.loopOracleMaxError);
end
