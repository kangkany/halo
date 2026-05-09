@echo off
setlocal enabledelayedexpansion

REM 用法：双击后输入目标目录，或命令行执行：
REM export_files.bat "D:\学习相关\【ddl】\【中期ddl】\复现\复现代码"

set "TARGET=%~1"
if "%TARGET%"=="" (
  set /p TARGET=请输入目标目录(例如 D:\学习相关\【ddl】\【中期ddl】\复现\复现代码): 
)

if "%TARGET%"=="" (
  echo 未提供目标目录，退出。
  exit /b 1
)

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"

call :copy_one "docs\matlab_viv_reproduction_guide.md"
call :copy_one "matlab-viv\+cfg\case_sway.m"
call :copy_one "matlab-viv\+mesh\build_mesh.m"
call :copy_one "matlab-viv\+model\assemble_MCK.m"
call :copy_one "matlab-viv\+model\boundary_update.m"
call :copy_one "matlab-viv\+model\hydrodynamic_force.m"
call :copy_one "matlab-viv\+model\soil_py_force.m"
call :copy_one "matlab-viv\+model\wake_rhs.m"
call :copy_one "matlab-viv\+post\calc_envelope.m"
call :copy_one "matlab-viv\+post\calc_rms.m"
call :copy_one "matlab-viv\+post\plot_profiles.m"
call :copy_one "matlab-viv\+post\plot_spectra.m"
call :copy_one "matlab-viv\+solver\step_newmark.m"
call :copy_one "matlab-viv\+solver\step_rk4.m"
call :copy_one "matlab-viv\main.m"

echo.
echo 已复制 15 个文件到: %TARGET%
echo 按任意键退出...
pause >nul
exit /b 0

:copy_one
set "REL=%~1"
set "SRC=%REPO_ROOT%\%REL%"
set "DST=%TARGET%\%REL%"
for %%D in ("%DST%") do set "DST_DIR=%%~dpD"
if not exist "%DST_DIR%" mkdir "%DST_DIR%"
copy /Y "%SRC%" "%DST%" >nul
if errorlevel 1 (
  echo [失败] %REL%
) else (
  echo [完成] %REL%
)
exit /b 0
