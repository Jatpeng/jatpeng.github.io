@echo off
echo Starting project initialization...

:: 检查必要的程序是否安装
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Git is not installed! Please install Git first.
    pause
    exit /b 1
)

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo Node.js is not installed! Please install Node.js first.
    pause
    exit /b 1
)

:: 克隆项目
echo Cloning the repository...
git clone git@github.com:Jatpeng/jatpeng.github.io.git blog
cd blog

:: 切换到 source 分支并拉取最新更新
echo Switching to source branch and pulling updates...
git checkout source
git pull origin source

:: 安装依赖
echo Installing dependencies...
call npm install

:: 安装主题相关依赖
echo Installing theme dependencies...
call npm install hexo-theme-next --save
call npm install hexo-deployer-git --save

:: 复制 push.bat（如果存在）
if exist push.bat (
    echo Copying deployment script...
    copy push.bat ..\push.bat
)

echo Project initialization completed!
echo You can now use 'hexo server' to start local development
echo Or use push.bat to deploy your changes
pause 