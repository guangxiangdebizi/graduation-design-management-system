@echo off
chcp 65001 >nul
set SQL_FILE=%~dp0init.sql
set SEED_FILE=%~dp0seed_demo_data_20260622.sql
set SHOWCASE_FILE=%~dp0seed_showcase_data_20260623.sql
set VISUAL_FILE=%~dp0seed_scope_visual_data_20260623.sql
set TEMP_SQL=%TEMP%\gd_init.sql
set TEMP_SEED=%TEMP%\gd_seed_demo.sql
set TEMP_SHOWCASE=%TEMP%\gd_seed_showcase.sql
set TEMP_VISUAL=%TEMP%\gd_seed_visual.sql
copy /Y "%SQL_FILE%" "%TEMP_SQL%" >nul
mysql -u root -p12345 --default-character-set=utf8mb4 -e "source %TEMP_SQL:/=\%"
if exist "%SEED_FILE%" (
  copy /Y "%SEED_FILE%" "%TEMP_SEED%" >nul
  mysql -u root -p12345 --default-character-set=utf8mb4 graduation_design -e "source %TEMP_SEED:/=\%"
)
if exist "%SHOWCASE_FILE%" (
  copy /Y "%SHOWCASE_FILE%" "%TEMP_SHOWCASE%" >nul
  mysql -u root -p12345 --default-character-set=utf8mb4 graduation_design -e "source %TEMP_SHOWCASE:/=\%"
)
if exist "%VISUAL_FILE%" (
  copy /Y "%VISUAL_FILE%" "%TEMP_VISUAL%" >nul
  mysql -u root -p12345 --default-character-set=utf8mb4 graduation_design -e "source %TEMP_VISUAL:/=\%"
)
echo Database initialized with UTF-8 encoding and demo seed data.
