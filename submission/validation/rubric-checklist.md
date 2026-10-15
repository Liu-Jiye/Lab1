# 评分标准逐项核对

本表按原始实验 DOCX 整理；证据均位于本提交目录。数值以 `results/summary.json` 和独立审计输出为准。教师未公开参考 HV，不能预先保证最终成绩。

| 任务 / 分值 | 满足方式与可复核证据 |
| --- | --- |
| Task 1 向量化评估器 / 10 | `matlab/power_objective.m`、`power_constraints.m`：N×5 输入，N×1 目标，N×5 约束与 SINR，空等式；独立循环 oracle 测试通过。 |
| Task 1 求解结果 / 20 | `results/ga_run_01.mat` 至 `ga_run_20.mat`；20 个独立种子，每次含初始化恰好 50,000 次候选评估；全部可行；中位数与 17.0014 的差远小于 0.10。 |
| Task 1 收敛图 / 5 | 报告 Figure 1；保存全部 20 条每代历史，初始种群计入；未可行时 Inf，跨全部 20 次取中位数。 |
| Task 1 统计 / 5 | 报告第 4 节：best/worst/mean/median/样本标准差、可行率、全 20 次首次可行评估次数中位数和逐次结果。 |
| Task 1 参数解释 / 10 | 报告第 2–3 节：种群、交叉、变异、选择压力、精英生存、约束比较与修复参数；无内置 ga/gamultiobj/CVX。 |
| Task 2 MOEA/D 实现 / 12 | `matlab/run_moead.m` 和报告第 5 节/附录：分解、201 权重、20 邻域、DE/多项式变异、理想点、最多两次替换、外部档案；自主实现主要流程。 |
| Task 2 约束处理 / 8 | 可行性优先、违反量比较、从已获得可行父代进行不使用目标的线段修复；采用向内 1e-12 约束余量防止浮点边界误判。 |
| Task 2 超参数 / 5 | 报告第 5 节逐项说明尺度、权重、邻域、F、CR、eta、替换次数和代数。 |
| Task 2 报告 / 10 | 英文 PDF 完整模型、算法、图表、运行结果、验证、来源和完整 MOEA/D 注释代码；正文解释目标方向和取典型运行方法。 |
| Task 2 HV / 15 | 三个独立运行，r=[26,0]，精确二维并集；中位 HV 运行作为典型。独立 HV 数值上界用于质量证据；未公开教师参考值，不虚构比值。 |
| 必交 MAT | `results/pareto_typical.mat` 内有 K×5 `paretoSet` 与 K×2 `paretoFront`，逐行对应，严格可行且互不支配。 |
| 不提交未修改工具箱 | 外部工具箱未打包；公开镜像及 commit 见 `PROVENANCE.md`。课程 SharePoint 返回 403，不能确认版本与课程分发完全相同。 |

## 复核与提交范围

- `implementation_tests.mat`：评估器、接口、手算 HV 和线段修复测试。
- `results_audit.json`：MATLAB 对所有结果复核。
- `independent_audit.json`：NumPy 独立目标/SINR、两两支配与不同积分公式 HV。
- `hv_upper_bound.json`、`hv_upper_bound_bins.csv`：与搜索隔离的数值质量诊断。
- PDF 所有页面均渲染检查；原始数据不根据期望数值手工改写。

最终确认事项：教师参考前沿未公开；课程专用工具箱版本未取得。已在报告如实说明，不能将这两项表述为无条件保证满分。
