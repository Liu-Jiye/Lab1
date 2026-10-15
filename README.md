# Stanford 五链路功率控制实验

本仓库整理通信功率控制实验的原始说明与 MATLAB 起始代码。实验使用五对发射机与接收机共享同一频段的模型，要求实现 GA 最小化总发射功率，并实现 MOEA/D 求解总功率与总速率之间的双目标优化。

目前包含原始资料和阅读笔记，GA、MOEA/D、种群向量化评估器及实验结果仍待实现。两份起始代码保留原样。

## 文件目录

```text
Lab1/
├── README.md
├── docs/
│   ├── Lab - Stanford Power Control (1).docx
│   └── lab-notes.zh-CN.md
└── src/
    ├── power_objective.m
    └── power_constraints.m
```

| 文件 | 用途 |
| --- | --- |
| [实验说明](docs/Lab%20-%20Stanford%20Power%20Control%20%281%29.docx) | 原始任务、评分标准与提交要求，内容未修改 |
| [中文阅读笔记](docs/lab-notes.zh-CN.md) | 数学模型、代码接口、实验要求和待完成事项 |
| [power_objective.m](src/power_objective.m) | 单个候选解的总发射功率 |
| [power_constraints.m](src/power_constraints.m) | 单个候选解的五个 SINR、非线性不等式约束和空等式约束 |

## 起始代码调用

在 MATLAB 中进入仓库根目录，执行：

```matlab
addpath('src');
power = [4, 4, 4, 4, 4];
objective = power_objective(power);
[constraint, equalityConstraint, sinrValue] = power_constraints(power);
isFeasible = all(power >= 0.1 & power <= 5) && all(constraint <= 0);
```

这个示例仅演示函数接口，并非优化求解器。起始函数接受含 5 个元素的行向量或列向量，内部转换为行向量；不能直接输入 N×5 种群。约束函数不检查功率上下界，调用方需自行处理。

## 实验要求概览

| 项目 | Task 1：GA | Task 2：MOEA/D |
| --- | --- | --- |
| 目标 | 最小化总发射功率 | 最小化总功率和负总速率 |
| 可行域 | 每个功率在 [0.1, 5]，每个 SINR ≥ 2 | 同 Task 1 |
| 独立运行 | 20 次，每次最多 50,000 次函数评估 | 3 次，取 HV 居中的一次作为典型运行 |
| 图表 | 20 次运行的中位数收敛曲线和最终可行结果统计表 | 可行非支配 Pareto 前沿图，横轴 f1、纵轴 f2 |
| 其他输出 | 可行运行率、首次可行所需评估次数的中位数 | Pareto 集与前沿的 MAT 文件、参考点 [26, 0] 的 HV |

禁止使用 MATLAB 内置 `ga`、`gamultiobj` 代替所要求的算法。Task 1 应基于课程 GA Toolbox 的算子构建 GA；工具箱未包含在本次提供的三个文件中。Stanford/CVX 示例仅可作为背景和独立参考，不能将其中的 CVX 求解器作为 GA 作业提交。

## 建议阅读顺序

1. 阅读原始实验说明，确认任务与评分标准。
2. 阅读中文笔记，理解 SINR、约束方向和结果统计口径。
3. 阅读两份 MATLAB 起始函数，先理解单个解的计算，再完成种群向量化。
4. 实现 GA 与 MOEA/D，保留随机种子、评估次数、运行日志和原始结果。
5. 按原始说明提交修改后的评估器、算法代码、所需 MAT 文件和 PDF 报告；不要提交未经修改的工具箱文件。

背景参考：[Stanford/CVX power-control example](https://cvxr.com/cvx/examples/gp_tutorial/html/power_control.html)。
