# 用法：在 PowerShell 执行
# .\export_files.ps1 -TargetDir "D:\学习相关\【ddl】\【中期ddl】\复现\复现代码"

param(
  [Parameter(Mandatory=$true)]
  [string]$TargetDir
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$files = @(
  "docs/matlab_viv_reproduction_guide.md",
  "matlab-viv/+cfg/case_sway.m",
  "matlab-viv/+mesh/build_mesh.m",
  "matlab-viv/+model/assemble_MCK.m",
  "matlab-viv/+model/boundary_update.m",
  "matlab-viv/+model/hydrodynamic_force.m",
  "matlab-viv/+model/soil_py_force.m",
  "matlab-viv/+model/wake_rhs.m",
  "matlab-viv/+post/calc_envelope.m",
  "matlab-viv/+post/calc_rms.m",
  "matlab-viv/+post/plot_profiles.m",
  "matlab-viv/+post/plot_spectra.m",
  "matlab-viv/+solver/step_newmark.m",
  "matlab-viv/+solver/step_rk4.m",
  "matlab-viv/main.m"
)

foreach ($rel in $files) {
  $src = Join-Path $repoRoot $rel
  $dst = Join-Path $TargetDir $rel
  $dstDir = Split-Path -Parent $dst
  New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
  Copy-Item -Path $src -Destination $dst -Force
}

Write-Host "已复制 15 个文件到: $TargetDir"
