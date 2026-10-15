"""Independent NumPy verification of MATLAB results, including union-area HV."""
from pathlib import Path
import json, hashlib
import numpy as np
from scipy.io import loadmat
R=Path(__file__).resolve().parents[1]
evidence=json.loads((R/'validation/course_toolbox_runtime.json').read_text())
manifest=json.loads((R/'validation/course_toolbox_manifest.json').read_text())
assert evidence['passed']
for name, info in evidence['operators'].items():
    expected=next(item for item in manifest['files'] if item['name']==name+'.m')
    assert info['sha256']==expected['sha256']
    assert hashlib.sha256(Path(info['path']).read_bytes()).hexdigest()==expected['sha256']
G=np.array([[1,.1,.2,.1,0],[.1,1,.1,.1,0],[.2,.1,2,.2,.2],[.1,.1,.2,1,.1],[0,0,.2,.1,1.]])
H=G-np.diag(np.diag(G))
def evaluate(x):
    x=np.atleast_2d(x); sinr=x*np.diag(G)/(.5+x@H.T)
    f=np.c_[x.sum(1),-np.log2(1+sinr).sum(1)]
    assert np.all((x>=.1)&(x<=5)) and np.all(sinr>=2)
    return f,sinr

ga=loadmat(R/'results/ga_results.mat',simplify_cells=True)
final=[]; first=[]
for run in ga['gaRuns']:
    for name,info in evidence['operators'].items():
        assert run['toolboxOperators'][name]==info['path']
    f,s=evaluate(run['power']); assert abs(f[0,0]-run['objective'])<1e-10
    h=np.asarray(run['history']); finite=h[np.isfinite(h)]
    assert len(h)==250 and np.all(np.diff(finite)<=1e-10)
    assert run['evaluations']==50000 and abs(finite[-1]-f[0,0])<1e-10
    final.append(f[0,0]); first.append(run['firstFeasibleEvaluations'])
assert len(final)==20 and abs(np.median(final)-17.0014)<.1
m=loadmat(R/'results/moead_results.mat',simplify_cells=True)
hvs=[]; counts=[]; min_sinr=[]
for run in m['moeadRuns']:
    assert run['evaluations']==201201 and len(run['hvHistory'])==1001
    f,s=evaluate(run['paretoSet']); front=run['paretoFront']
    assert np.max(np.abs(f-front))<1e-10
    # Independent pairwise nondomination rather than the MATLAB scan.
    for point in front:
        assert not np.any(np.all(front<=point,axis=1)&np.any(front<point,axis=1))
    # Integrate horizontal strips between successive x coordinates.
    order=np.argsort(front[:,0]); q=front[order]
    width=np.diff(np.r_[q[:,0],26.]); hv=float(np.dot(width,-q[:,1]))
    assert abs(hv-run['hv'])<1e-9
    assert np.all(np.diff(run['hvHistory'])>=-1e-10)
    hvs.append(hv); counts.append(len(front)); min_sinr.append(float(s.min()))
p=loadmat(R/'results/pareto_typical.mat',simplify_cells=True)
assert abs(p['typicalHV']-np.median(hvs))<1e-10
result={'passed':True,'course_toolbox_verified':True,'ga_runs':20,'ga_min':min(final),'ga_max':max(final),
'ga_mean':float(np.mean(final)),'ga_median':float(np.median(final)),
'ga_sample_std':float(np.std(final,ddof=1)),'median_first_feasible':float(np.median(first)),
'moead_hv':hvs,'pareto_counts':counts,'minimum_pareto_sinr':min_sinr,
'checks':['course operator SHA-256 and runtime resolution','independent SINR/objective recomputation','strict feasibility',
'pairwise nondomination','alternative HV strip integration','run count and budgets',
'GA monotone best-so-far history','median-HV typical selection']}
(R/'validation/independent_audit.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps(result,indent=2))
