function WindowsBootstrap {
  choco install azure-cli
  choco install terraform
}

function MacOSBootstrap {
  brew install azure-cli
  brew install terraform
}

function DebianBootstrap {
  throw "Not yet implemented"
}

function RedHatBootstrap {
  throw "Not yet implemented"
}

if(($PSVersionTable.PSVersion.Major -lt 6) -or $isWindows)
{
  WindowsBootstrap
  return
}

if($isMacOS){
  MacOSBootstrap
}

if($isLinux){
  if(Get-Command "yum" -ErrorAction SilentlyContinue){
    RedHatBootstrap
  }elseif (Get-Command "apt" -ErrorAction SilentlyContinue) {   
    DebianBootstrap
  }else {
    Throw "You are running an unsupported Linux distro"
  }

}