@echo off
chcp 65001 >nul
set SQL_FILE=%~dp0init.sql
set TEMP_SQL=%TEMP%\gd_init.sql
copy /Y "%SQL_FILE%" "%TEMP_SQL%" >nul
mysql -u root -p12345 --default-character-set=utf8mb4 -e "source %TEMP_SQL:/=\%"
echo Database initialized with UTF-8 encoding.
