# Ready-to-submit ZIP contents

This folder contains the complete submission for both tasks. Submit `final_submission.zip` from the repository root. Original, unmodified course toolbox files are excluded.

| Requirement | Files in this folder |
| --- | --- |
| Modified vectorized evaluators | `matlab/power_objective.m`, `matlab/power_constraints.m` and supporting functions |
| Task 1 GA source | `matlab/run_ga.m` and supporting functions in `matlab/` |
| Task 2 MOEA/D source | `matlab/run_moead.m` and supporting functions in `matlab/` |
| Required Pareto set and front MAT | `results/pareto_typical.mat` contains both `paretoSet` and `paretoFront` |
| One PDF covering both tasks | `report/lab_report.pdf` |

Keep the full folder structure: the experiment driver also uses the validation manifest. Additional results and validation files provide reproducibility evidence. The course toolbox must be supplied separately when rerunning the code.

---

# Final submission using the supplied course GA Toolbox

All 20 GA and three MOEA/D runs were freshly executed with no reused result MAT files. The nine-page English report and all required deliverables are contained here.

- `report/lab_report.pdf`: model, algorithms, justified parameters, statistics, plots, HV and commented MOEA/D code appendix.
- `matlab/`: vectorized evaluators, GA, MOEA/D, repair, archive, HV, experiment driver and verification.
- `results/`: all 23 raw runs, complete histories, summaries, CSV and required `pareto_typical.mat`.
- `validation/`: rubric mapping, course source hashes/runtime paths, MATLAB and independent Python audits, execution log, PDF QA and SHA-256 inventory.

## Reproduction

MATLAB R2024b was used. The external course toolbox is `C:/Users/25735/Downloads/OneDrive_1_2026-10-15`. Its original files were not modified, including line endings and DOS EOF markers. The five dependencies are ranking, sus, recint, mutbga and rep. Unmodified toolbox source is excluded from submission as required by the assignment.

```matlab
cd('C:/Users/25735/Lab1');
addpath('final_submission/matlab','-begin');
run_all('C:/Users/25735/Downloads/OneDrive_1_2026-10-15',false);
```

On another machine, supply the course toolbox directory. The startup verifier checks original SHA-256 and MATLAB resolution against `validation/course_toolbox_manifest.json`. Course ranking requires `ranking(cost,[1.8 0])`, explicitly selecting linear ranking. The GA applies 0.9 crossover probability separately because recint ignores XOVR. The command reruns all experiments and overwrites this directory's results. Formal execution used resume=false.

To audit saved data:

```matlab
addpath('final_submission/matlab','-begin');
validate_implementation();
verify_results();
```

Python dependencies: numpy, scipy, matplotlib and reportlab; PyMuPDF for PDF rendering.

```powershell
python final_submission/validation/independent_audit.py
python final_submission/validation/hv_upper_bound.py
python final_submission/report/build_report.py
```

The Python source audit reads the original runtime paths; after moving machines, first rerun the MATLAB driver to refresh them.

## Budgets, feasibility and files

GA seeds 11001-11020; population 200; exactly 50,000 candidate evaluations per run including initialization; all 250 generation records retained. Statistics use feasible final runs. Median convergence and first-feasible counts cover all 20 runs. Pre-feasibility histories are Inf.

MOEA/D seeds 21001-21003; 201 subproblems, neighborhood 20, 1,000 generations; 201,201 candidate evaluations per run including initialization. Reference point [26,0]. Select the run with median final HV. `pareto_typical.mat` contains corresponding 5811-by-5 paretoSet and 5811-by-2 paretoFront, strictly feasible and mutually nondominated.

Bounds are [0.1,5] and all SINR values must be at least 2. GA uses c<=0; MOEA/D searches with inward c<=-1e-12, while final audits check original mathematical feasibility. No 1e-4 relaxation is used. Repair uses linear inequalities and previously evaluated feasible anchors, with no objective call. Post-search audits are separate from search evaluation budgets.

No built-in ga, gamultiobj, CVX or other optimizer generates evolutionary candidates. Independent SciPy quality diagnostics run after the experiments and do not inject solutions. See `validation/PROVENANCE.md` for sources and assistance disclosure.
