# Stanford 五链路功率控制实验

实验已完成，完整提交材料放在独立文件夹 **[submission/](submission/)**。原始任务说明与起始代码保留在 `docs/`、`src/`，便于追溯。

- **[PDF 实验报告](submission/report/lab_report.pdf)**：模型、GA、MOEA/D、参数理由、完整实验统计、图表与注释代码附录。
- **[运行与复现说明](submission/README.md)**：依赖、命令、评估预算和约束口径。
- **[评分项核对表](submission/validation/rubric-checklist.md)**：逐项对应原题要求与证据。
- **[典型 Pareto 集与前沿 MAT](submission/results/pareto_typical.mat)**：题目要求的 K×5 与 K×2 数据。
- **[原始实验说明](docs/Lab%20-%20Stanford%20Power%20Control%20%281%29.docx)**：任务与评分依据。

20 次 GA、3 次 MOEA/D 的种子、原始结果、收敛历史、统计和独立核验均保存在提交目录。GA 基于 Sheffield GA Toolbox 算子，MOEA/D 自行实现，未调用 MATLAB 内置 `ga`、`gamultiobj` 或 CVX 优化器。课程下载链接无法访问，公开工具箱来源和版本限制已明确披露。

```text
submission/
├── matlab/       # 向量化评估器、GA、MOEA/D、HV、复现与验证
├── results/      # 23 次原始结果、典型 Pareto MAT、CSV、JSON
├── report/       # PDF、生成脚本、图表
└── validation/   # 评分核对、独立审计、数值上界、来源
```

详见提交目录；`docs/lab-notes.zh-CN.md` 为最初阅读记录，其“待办”描述反映归档时状态，完成状态以本页和 `submission/` 为准。
