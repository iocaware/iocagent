REM 
echo "Stopping Service"
call sc stop IOCA
echo "Removing logs"
call del "C:\Program Files (x86)\IOCAware\*.log"
echo "Building executable"
call ocra --no-autoload --output iocaware.exe .\ioc_agent.rb .\agent.rb .\utils.rb
echo "Deploying executable"
call copy iocaware.exe ".\installer"
call copy iocaware.exe "C:\Program Files (x86)\IOCAware"
echo "Start Service"
call sc start IOCA
echo "Done"