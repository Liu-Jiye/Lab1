# Original rubric checklist: course-toolbox submission

Mapped to both original DOCX marking tables. This records completed evidence and the highest numerical result bracket, not an assigned grade. Instructor reference-HV files are outside this task's scope, as requested.

| Criterion | Marks | Evidence |
| --- | ---: | --- |
| Task 1 vectorized evaluators | 10 | N-by-5 input; N-by-1 objective; N-by-5 constraints/SINR; empty equalities. Independent loop oracle max error 8.88e-16. |
| Task 1 result | 20 | 20 independent runs, each 50,000 evaluations including initialization; 20/20 strictly feasible. Median 17.001367487497; absolute reference difference 0.0000325125 < 0.10, satisfying the explicit 18-20 highest-bracket condition. |
| Task 1 plot | 5 | Figure 1 correctly labels evaluations and best feasible power; median across all 20 every-generation histories, with original histories retained. |
| Task 1 table | 5 | Section 4 reports best/worst/mean/median/sample standard deviation, feasible rate, and median first-feasible evaluation count 1619 over all runs; Section 4.1 lists each run. |
| Task 1 explanation | 10 | Sections 2-3 justify population, 0.9 crossover, 0.2 mutation and shrink, ranking/SUS, elitism, feasibility-first handling and 0.98 repair contraction. Course operator paths and hashes pass verification. |
| Task 2 MOEA/D implementation | 12 | Self-implemented 201 weights, 20 neighbors, Tchebycheff decomposition, DE/polynomial mutation, ideal point, at-most-two replacement and external archive. Complete commented main/mutation code in report appendix; support functions submitted. |
| Task 2 constraint handling | 8 | Bound clipping, feasibility-first comparison and segment repair; all three archives strictly satisfy bounds and SINR>=2, and are mutually nondominated. MATLAB and NumPy audit every saved point. |
| Task 2 hyperparameters | 5 | Section 5 justifies weights, neighborhood, 0.9 local mating, F=0.5, CR=0.9, mutation probability/eta=20, scales [8,1.5], replacement limit and 1,000 generations. |
| Task 2 report | 10 | Nine-page English PDF: model, algorithms, rationale, results, Pareto plot with f1 horizontal/f2 vertical, HV, commented source, provenance and reproduction; all pages rendered and inspected. |
| Task 2 HV | 15 | Three independent runs; strictly feasible archives; reference [26,0]; exact 2-D union with independent strip integration. Median run 3 has HV=73.8399394753. Supplementary floating-point upper-bound coverage is approximately 99.834%; it is a quality diagnostic. |

## Required deliverables and restrictions

- Revised vectorized evaluators and GA/MOEA/D/support source: `matlab/`.
- `results/pareto_typical.mat`: 5811-by-5 paretoSet and 5811-by-2 paretoFront, corresponding rows, strict feasibility and mutual nondomination; median-HV run selection.
- PDF: `report/lab_report.pdf`; raw run MAT files, histories, CSV and summary JSON: `results/`.
- Unmodified toolbox files excluded; external course dependency has exact-byte and runtime-path evidence.
- No ga/gamultiobj/CVX candidate generation; independent numerical diagnostics isolated from the evolutionary search.

## Verification records

`course_toolbox_runtime.json`: exact course source and resolution; `implementation_tests.mat`: implementation tests; `results_audit.json`: MATLAB audit; `independent_audit.json`: independent NumPy audit; `course_formal_runs.log`: actual fresh run log; `pdf_visual_qa.json`: full-page review; `SHA256SUMS.txt`: file inventory.
