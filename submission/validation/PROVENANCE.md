# Sources and experiment provenance

1. Assignment: `../../docs/Lab - Stanford Power Control (1).docx`. Source for both tasks, constraints, budgets, required outputs and rubric. The document is the authority where commentary differs.
2. Starter evaluators: `../../src/power_objective.m`, `../../src/power_constraints.m`. Revised population evaluators are in `../matlab/`; the original files remain intact.
3. GA operators: Sheffield Genetic Algorithm Toolbox, Hartmut Pohlheim and Carlos Fonseca (operator headers), public mirror https://github.com/sumatrae/gatbx at commit `0cd0a5612edd6b0d5d97214927d1452fbac46986`. Used `ranking`, `sus`, `recint`, `mutbga`, and dependency `rep`. The mirror retains GPL text; these files are external dependencies and are not redistributed in this submission. Only `.M` filename extensions were normalized to `.m` in the external runtime copy. The implementation records linear-ranking pressure 1.8; SUS sampling; extended intermediate crossover with coefficient in [-0.25,1.25]; BGA mutation. The wrapper explicitly applies crossover probability because `recint` ignores its second argument.
4. Stanford/CVX background: https://cvxr.com/cvx/examples/gp_tutorial/html/power_control.html . No CVX source or solver is used or adapted. The given 17.0014 reference is used only after optimization for comparison, not to initialize or update candidates.
5. MOEA/D: Q. Zhang and H. Li, “MOEA/D: A Multiobjective Evolutionary Algorithm Based on Decomposition,” IEEE Transactions on Evolutionary Computation, 11(6), 712-731, 2007, doi:10.1109/TEVC.2007.892759. Independently implemented normalized Tchebycheff decomposition, DE variation, polynomial mutation, neighborhood mating and bounded replacement.
6. Feasibility-first selection: K. Deb, “An efficient constraint handling method for genetic algorithms,” Computer Methods in Applied Mechanics and Engineering, 186, 311-338, 2000, doi:10.1016/S0045-7825(99)00389-8. The implementation additionally uses an objective-free feasible-segment repair derived directly from the SINR inequalities.

## Separation of validation and optimization

`hv_upper_bound.py` invokes SciPy LP and SLSQP only for an independent numerical quality bound. Neither MATLAB algorithm reads its files or uses its candidate points. Its LP total-power minimum and rate maximization diagnostics are not algorithm outputs. A fixed feasible fixture in `validate_implementation.m` tests repair but is never passed into GA or MOEA/D. Formal experiments begin from independent uniform random populations; no reference-optimal candidate or CVX solution is injected.

The only development pilot seeds were GA 9101 and MOEA/D 9201. Formal seeds were fixed as 11001-11020 and 21001-21003 before the formal run. Population/generation settings are recorded in MAT files. Pilots are not included in assessed run statistics. Random generator: MATLAB `rng(seed,'twister')`.

This work was implemented and analyzed with Codex assistance. The recipient should comply with their institution's disclosure rules and understand the algorithms before submission. No claim is made that the material was produced without assistance.

## Numerical boundary correction

An initial three-run MOEA/D audit exposed differences of a few ulps between scalar and batch matrix products at SINR=2. All three MOEA/D runs were repeated with unchanged seeds/budgets and an inward c<=-1e-12 acceptance margin. Only the final validated results are submitted. GA uses the original c<=0 test; its cached formal runs are unchanged. Validation checks the mathematical constraints, not the additional search margin.
