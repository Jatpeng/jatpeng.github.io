@echo off
echo Starting Hexo deployment process...

:: 设置工作目录为脚本所在目录
cd /d "%~dp0"

:: 检查 Git 是否可用
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Git is not installed or not in PATH
    pause
    exit /b 1
)

:: 清理和生成
call hexo clean
call hexo generate

:: 添加所有更改
echo Adding changes to git...
git add .

:: 获取当前时间作为提交信息
set "datetime=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "commit_msg=Update site %datetime%"

:: 提交更改
echo Committing changes...
git commit -m "%commit_msg%"

:: 确保在 source 分支
echo Checking out source branch...
git checkout source

:: 推送到远程仓库
echo Pushing to remote repository...
git push origin source

if %errorlevel% neq 0 (
    echo Error occurred during git operations
    pause
    exit /b 1
)

:: 部署到 GitHub Pages
echo Deploying to GitHub Pages...
call hexo deploy

echo Deployment completed successfully!
pause 