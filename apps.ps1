#
# Apps for development machine
#

choco upgrade -y git --params "/NoShellIntegration"
choco upgrade -y gh
choco upgrade -y 7zip
choco upgrade -y notepad2-mod
choco upgrade -y totalcommander
choco upgrade -y sublimemerge
choco upgrade -y winmerge
choco upgrade -y powershell-core
choco upgrade -y microsoft-windows-terminal

choco upgrade -y cascadiamono
choco upgrade -y cascadiamonopl
choco upgrade -y cascadiacodepl

choco upgrade -y hashcheck

choco install nodejs-lts --version=16.18.1
choco upgrade -y yarn


# extra apps
# choco upgrade -y firefox
