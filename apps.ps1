#
# Apps for development machine
#

choco upgrade -y git --params "/NoShellIntegration"
choco upgrade -y 7zip
choco upgrade -y notepad2-mod
choco upgrade -y totalcommander
choco upgrade -y sublimemerge
choco upgrade -y winmerge
choco upgrade -y powershell-core
choco upgrade -y microsoft-windows-terminal

choco upgrade -y cascadiamono
choco upgrade -y cascadiacodepl

choco upgrade -y hashcheck


# extra apps
choco upgrade -y firefox

choco upgrade -y minishift
choco upgrade -y openshift-cli

choco upgrade -y jdk8 --x86
choco upgrade -y maven
choco upgrade -y ant
