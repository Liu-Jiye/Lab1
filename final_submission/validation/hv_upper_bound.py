"""Independent HV upper bound; never supplies points to GA or MOEA/D.

For a fixed total-power budget t, SINR constraints are linear. On each
interference interval [l,u], the chord of convex -log2(I) is an upper bound.
Adding concave log2(total received power) yields a concave rate majorant U.
The tangent of U at ANY interior feasible point is an affine global upper
bound. Its LP maximum gives a valid rate bound even if SLSQP fails to find
the maximizer. Right-endpoint integration gives an upper bound on true HV.
All LP bounds are padded for floating-point roundoff (not interval proofs).
"""
from pathlib import Path
import json
import numpy as np
from scipy.optimize import linprog, minimize

ROOT=Path(__file__).resolve().parents[1]
G=np.array([[1,.1,.2,.1,0],[.1,1,.1,.1,0],[.2,.1,2,.2,.2],[.1,.1,.2,1,.1],[0,0,.2,.1,1.]])
H=G-np.diag(np.diag(G)); A=2*H-np.diag(np.diag(G)); b=-np.ones(5)
bounds=[(.1,5)]*5

def lp(c,aa,bb):
    r=linprog(c,A_ub=aa,b_ub=bb,bounds=bounds,method='highs')
    if not r.success: raise RuntimeError(r.message)
    return r

def rate(x):
    return np.log2((.5+G@x)/(.5+H@x)).sum()

minimum=lp(np.ones(5),A,b)
# Start slightly below the certified linear-program optimum; zero true HV
# is accumulated below the attainable minimum power.
start=float(minimum.fun)-1e-7
edges=np.r_[np.arange(start,25,.05),25.,26.]
rows=[]; previous=minimum.x.copy()
for left,right in zip(edges[:-1],edges[1:]):
    aa=np.vstack([A,np.ones(5)]); bb=np.r_[b,min(right,25.)+1e-10]
    low=[]; high=[]
    for h in H:
        low.append(.5+lp(h,aa,bb).fun-1e-8)
        high.append(.5-lp(-h,aa,bb).fun+1e-8)
    low=np.array(low); high=np.array(high)
    slope=(-np.log2(high)+np.log2(low))/(high-low)
    intercept=-np.log2(low)-slope*low
    def majorant(x):
        total=.5+G@x; interference=.5+H@x
        return np.log2(total).sum()+np.dot(slope,interference)+intercept.sum()
    def gradient(x):
        return G.T@(1/(np.log(2)*(.5+G@x)))+H.T@slope
    opt=minimize(lambda x:-majorant(x),previous,jac=lambda x:-gradient(x),
        bounds=bounds,constraints=[{'type':'ineq','fun':lambda x:bb-aa@x,'jac':lambda x:-aa}],
        method='SLSQP',options={'ftol':1e-12,'maxiter':150})
    point=opt.x
    tangent_lp=lp(-gradient(point),aa,bb)
    upper=majorant(point)+np.dot(gradient(point),tangent_lp.x-point)+1e-7
    # A separate attainable rate sample is diagnostic only.
    diag=minimize(lambda x:-rate(x),point,bounds=bounds,
        constraints=[{'type':'ineq','fun':lambda x:bb-aa@x}],method='SLSQP',
        options={'ftol':1e-11,'maxiter':100})
    previous=diag.x
    rows.append([left,right,upper,rate(diag.x),float(opt.success)])
rows=np.array(rows); upper_hv=float(np.sum(np.diff(edges)*rows[:,2]))
summary={'method':'concave chord majorant, tangent LP, right rectangles',
    'minimum_power_lp':float(minimum.fun),'power_bin_width':.05,
    'true_hv_upper_bound_numerical':upper_hv,'bins':len(rows),
    'roundoff_padding':'1e-8 interference, 1e-7 rate, 1e-7 minimum power',
    'scope':'Independent diagnostic only; no points enter evolutionary algorithms; not an interval-arithmetic proof.'}
p=ROOT/'results'/'summary.json'
if p.exists():
    student=json.loads(p.read_text(encoding='utf-8'))['typicalHV']
    summary['typical_student_hv']=student
    summary['student_hv_over_upper_bound']=student/upper_hv
np.savetxt(ROOT/'validation'/'hv_upper_bound_bins.csv',rows,delimiter=',',header='left,right,rate_upper,diagnostic_attainable_rate,slsqp_success',comments='')
(ROOT/'validation'/'hv_upper_bound.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
print(json.dumps(summary,indent=2))
