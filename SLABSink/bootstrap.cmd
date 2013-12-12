powershell -command "Set-ExecutionPolicy RemoteSigned" > install.log 2>&1
powershell .\bootstrap.ps1 >> install.log 2>&1
