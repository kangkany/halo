# MATLAB 复现指南：Top-tensioned riser 三维 VIV（Ocean Engineering 313, 2024, 119626）

本文给出一个可执行的 MATLAB 复现路线，目标是从“论文模型思路”到“可运行代码框架”，并尽量对应文中的关键图（RMS 沿深度分布、位移包络、频谱）。

## 1. 复现目标与范围

建议把复现拆成三层：

1. **最小可运行版本（MVP）**
   - 仅 CF（横流）方向，忽略 IL（顺流）与扭转耦合。
   - 上边界只考虑平台 sway 的简谐位移输入。
   - 土体作用先用等效线性弹簧，后续再替换为 p-y 非线性。

2. **论文主模型版本**
   - CF + IL 双向耦合。
   - Van der Pol wake oscillator 与结构方程双向耦合。
   - Newmark-β 结构时间积分 + RK4 振子积分（分步耦合）。

3. **扩展验证版本**
   - 加入 heave/surge、tensioner 动态顶张力、pipe-soil 非线性。
   - 对比“with WH / without WH”与频谱峰值迁移。

## 2. 推荐工程目录

```text
matlab-viv/
  main.m
  +cfg/
    case_base.m
    case_sway.m
    case_surge.m
  +mesh/
    build_mesh.m
    shape_beam2node.m
  +model/
    assemble_MCK.m
    hydrodynamic_force.m
    soil_py_force.m
    wake_rhs.m
    boundary_update.m
  +solver/
    step_newmark.m
    step_rk4.m
    coupled_step.m
  +post/
    calc_rms.m
    calc_envelope.m
    calc_fft.m
    plot_profiles.m
    plot_spectra.m
  +util/
    nondim_check.m
    sanity_checks.m
```

## 3. 状态变量定义（建议）

- 结构自由度：
  - `q = [y_CF_nodes; x_IL_nodes]`（先做 CF 时仅 `y`）
  - `qd, qdd`
- 振子变量（每个单元或每个节点）：
  - `p, p_dot`（CF）
  - `qv, qv_dot`（IL，可选）
- 外载：
  - `F_hydro`, `F_soil`, `F_top`, `F_static`

## 4. 离散与组装要点

1. **梁单元离散**
   - 用 Euler-Bernoulli 2 节点梁单元（每节点可含位移 + 转角）。
   - 先在单平面（CF）实现，确认无误后再扩到 3D/双平面。

2. **质量、阻尼、刚度矩阵**
   - `M = M_struct + M_added`
   - `C = C_struct + C_hydro`（Rayleigh 或模态阻尼）
   - `K = K_struct + K_geo + K_soil_eq`

3. **边界条件**
   - 顶端：位移约束来自平台运动 `S(t)`（sway/surge/heave）。
   - 底端：井口/导管连接刚度 + 土体反力。

## 5. 流固耦合与时间推进（核心）

每个时间步 `n -> n+1`：

1. 由 `q_n, qd_n` 估计相对流速 `V_r`。
2. 用 RK4 更新 wake oscillator（`p, p_dot`）。
3. 由 `p` 计算升力/脉动力，组装 `F_hydro`。
4. 由当前位移求 `F_soil`（p-y 非线性可迭代）。
5. 进入 Newmark-β 更新结构：
   - 预测 `q_{n+1}`，迭代修正（若含强非线性建议牛顿迭代）。
6. 存储响应用于后处理。

> 建议参数：`beta = 1/4`, `gamma = 1/2`（平均加速度法，条件稳定）。

## 6. 先复现哪些图（优先级）

1. **RMS 沿深度分布**（最容易判定对错）
2. **位移包络图（CF/IL）**
3. **幅频谱（最大 RMS 位置）**

如果你发现：
- 主频位置对了但峰值不对：优先检查阻尼与顶张力。
- CF 对了 IL 不对：检查双向耦合项和相对速度定义。
- 井口附近偏差大：优先检查土体模型和下边界刚度。

## 7. 一个可直接跑的最小主程序骨架

```matlab
% main.m (MVP skeleton)
clear; clc;
cfg = cfg.case_sway();
[meshData, dof] = mesh.build_mesh(cfg);
[M,C,K] = model.assemble_MCK(cfg, meshData, dof);

nt = floor(cfg.T/cfg.dt);
q   = zeros(dof.n,1); qd  = zeros(dof.n,1); qdd = zeros(dof.n,1);
p   = zeros(meshData.ne,1); pdot = zeros(meshData.ne,1);

Qhist = zeros(dof.n, nt);
for n = 1:nt
    t = (n-1)*cfg.dt;

    bc = model.boundary_update(cfg, t);

    [p, pdot] = solver.step_rk4(@(pp,ppd) model.wake_rhs(pp,ppd,q,qd,cfg,meshData), p, pdot, cfg.dt);

    Fh = model.hydrodynamic_force(p, q, qd, cfg, meshData);
    Fs = model.soil_py_force(q, qd, cfg, meshData);
    F  = Fh + Fs + bc.Fext;

    [q, qd, qdd] = solver.step_newmark(M,C,K,F,q,qd,qdd,cfg.dt,cfg.beta,cfg.gamma,bc);

    Qhist(:,n) = q;
end

post.plot_profiles(meshData, post.calc_rms(Qhist));
```

## 8. 标定（非常关键）

- 论文里很多参数来自特定算例/引用文献（几何、流速剖面、张力系统、土体层参数）。
- 你要建立一份 `parameter_mapping.xlsx`，列出：
  - 论文符号
  - 物理含义
  - 单位
  - 代码变量名
  - 数据来源（论文页码/表格）

这一步常常决定复现能否成功。

## 9. 常见错误清单

1. 单位混乱（N/kN, Pa/MPa, m/mm）。
2. 顶端激励位移、速度、加速度相位关系错误。
3. 频谱没去稳态段（应截取后半段再 FFT）。
4. p-y 模型在大位移下未限幅导致数值爆振。
5. Newmark 更新中边界自由度处理不一致（删行删列 vs 罚函数法）。

## 10. 我建议你下一步这样做

1. 先告诉我你现在已有的内容：
   - 是否已写 FEM 梁单元？
   - 是否已写 Newmark？
   - 是否已有任意一张图接近论文？
2. 我可以基于你的现有代码，给你：
   - 逐文件补全清单；
   - 可直接粘贴的 MATLAB 函数模板（`assemble_MCK`, `step_newmark`, `wake_rhs`）；
   - 一个“先跑通再提精度”的调参顺序。

