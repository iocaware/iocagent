REM 
echo "Building executable"
call ocra --no-autoload --output iocaware.exe .\ioc_agent.rb .\agent.rb .\utils.rb
echo "Deploying executable"
call copy iocaware.exe ".\installer"
call copy iocaware.exe "C:\Program Files (x86)\IOCAware"
echo "Done"