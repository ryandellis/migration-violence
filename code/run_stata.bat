@echo off
cd /d %~dp0
(echo do %1) > _run_temp.do
(echo exit, STATA clear) >> _run_temp.do
"C:\Program Files\StataNow19\StataSE-64.exe" do _run_temp.do
del _run_temp.do
