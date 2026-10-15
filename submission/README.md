# 实验提交包

本目录是单独整理的提交材料，原始题目与起始代码保留在仓库的 `docs/` 与 `src/`。

## 内容

- `matlab/`：修改后的种群向量化评估器、GA、MOEA/D、精确二维 HV、复现实验与验证代码。
- `results/`：20 次 GA、3 次 MOEA/D 原始 MAT、典型运行 Pareto 集与前沿、CSV 和统计 JSON。
- `report/`：英文 PDF 实验报告、报告源代码、图表。
- `validation/`：独立评估器/HV/修复测试、结果审计、HV 上界诊断及来源说明。

## MATLAB 一键复现

要求 MATLAB R2024b 或兼容版本，以及外部 Sheffield GA Toolbox。未使用 MATLAB 内置 `ga`、`gamultiobj`、CVX 或其他内置多目标优化求解器。

```matlab
cd('你的路径/Lab1');
addpath('submission/matlab');
run_all('你的工具箱路径/gatbx');
```

工具箱须含可被 MATLAB 识别的小写 `.m` 文件：`ranking.m`、`sus.m`、`recint.m`、`mutbga.m` 和依赖 `rep.m`。公开镜像中的 `.M` 后缀在本机未被识别，需要只在外部工具箱目录将后缀改为 `.m`。

正式运行参数与种子固定在 `run_all.m`：GA 种子 11001-11020、种群 200、每次 50,000 次评估；MOEA/D 种子 21001-21003、201 个子问题、1,000 代、每次 201,201 次评估。`run_all` 会覆盖同名结果文件。

仅核验已保存的结果：

```matlab
addpath('submission/matlab');
verify_results();
```

报告生成与独立核验使用 Python 的 numpy、scipy、matplotlib、reportlab、pypdf、PyMuPDF。它们不参与生成进化算法的候选解。

```powershell
python submission/validation/independent_audit.py
python submission/validation/hv_upper_bound.py
python submission/report/build_report.py
```

## 约束与评估次数

所有最终结果均按功率在 [0.1,5]、五条 SINR >= 2 的严格条件筛选，MOEA/D 搜索可行性接受条件进一步采用 c_i <= -1e-12 的向内余量，避免标量与批量计算的边界舍入差异。GA 没有使用题目允许的 1e-4 约束违反量来放宽可行域。20 次运行的最终目标统计只纳入可行运行，标准差使用样本标准差。

一次评估指评估一个候选功率向量，同时返回目标与约束不重复计数。初始化种群计入预算；每代所有子代（包括重复解和修复后解）计入预算。父代适应度复用；保存结果后的独立核验不属于优化搜索评估。修复只处理边界/线性不等式，不调用目标函数或求解优化问题。

GA 的每代历史值为严格可行历史最优值；尚无可行解时记录 Inf。首次可行按实际评估顺序定位到批内个体。MOEA/D 的每一代按随机子问题顺序逐个评估和替换，外部档案每代合并所有新评估的严格可行解，不截断档案。

## 来源与评分核对

详见 `validation/PROVENANCE.md` 和 `validation/rubric-checklist.md`。课程工具箱 SharePoint 链接本次访问返回 403，因此采用公开 Sheffield 镜像进行实验；尚不能确认它与课程提供的版本逐文件一致。按照题目要求，提交包不包含未经修改的工具箱文件。

HV 参考前沿未公开，不能声称已获得教师的满分或精确评分比值。独立数值上界诊断用于评估前沿质量，并明确其浮点数值性质。完整评分仍由教师按原始题目判定。
