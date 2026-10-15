# Sources and course-toolbox rerun provenance

1. Assignment authority: `../../docs/Lab - Stanford Power Control (1).docx`, read in full including both marking tables. Original starter evaluators remain at `../../src/`.
2. GA dependency: the user-supplied course GA Toolbox at `C:/Users/25735/Downloads/OneDrive_1_2026-10-15`, attributed to Hartmut Pohlheim / Carlos Fonseca in its headers. The entire download is inventoried in `course_toolbox_manifest.json`. Runtime SHA-256 and MATLAB resolution for `ranking`, `sus`, `recint`, `mutbga` and `rep` are checked by `verify_course_toolbox.m` and saved in `course_toolbox_runtime.json`. Each GA result also records all five operator paths. No original toolbox source is included in the submitted package, following the explicit assignment instruction.
3. The course files retain original legacy CRCRLF line endings and DOS EOF bytes; MATLAB R2024b executed them directly. No source, filename or extension was modified. This submission does not use the earlier public mirror. The course `ranking` interface is explicitly invoked as `[1.8,0]` (pressure and linear-mode flag). `recint` documents that XOVR is ignored; the GA wrapper applies crossover probability explicitly.
4. Stanford background: https://cvxr.com/cvx/examples/gp_tutorial/html/power_control.html . No CVX solver is used, adapted or submitted. The 17.0014 value is used only for post-search comparison, never candidate construction.
5. MOEA/D: Q. Zhang and H. Li, IEEE TEC 11(6), 2007, doi:10.1109/TEVC.2007.892759. The MATLAB implementation includes normalized Tchebycheff decomposition, evenly spaced weights, neighborhoods, DE, polynomial mutation, bounded replacement and an exact feasible nondominated archive.
6. Feasibility-first selection: K. Deb, CMAME 186, 2000, doi:10.1016/S0045-7825(99)00389-8. Segment repair is derived from the given SINR inequalities and uses already evaluated feasible anchors.

## Fresh execution and validation

All 20 GA runs and all three MOEA/D runs were executed anew with the original fixed seeds and budgets using `run_all(coursePath,false)`. No cached MAT results were reused. The execution log is `course_formal_runs.log`. Matching numerical results with the earlier run are consistent with deterministic seeds and equivalent operator formulas on the selected linear-ranking path; they are not evidence of reused output. New timestamps, runtime provenance and raw run records are retained.

Formal seeds are GA 11001?11020 and MOEA/D 21001?21003; MATLAB `rng(seed,'twister')`. Every assessed run is reported, without choosing or excluding runs by final quality. Each experiment starts from an independent uniform random population. No reference optimum, LP/SLSQP/CVX solution or interpolated point is injected into the search.

`hv_upper_bound.py` uses SciPy only after the searches for a supplementary floating-point quality diagnostic. It is isolated from the MATLAB candidate generators. A fixed feasible fixture used in implementation tests is never provided to either optimizer. MATLAB and independent NumPy audits validate strict feasibility, objective correspondence, budgets, histories, nondomination and median-HV selection.

Codex assisted implementation, analysis and report preparation. The recipient should understand the algorithms and follow institutional disclosure requirements. No claim is made that this work was produced without assistance.
