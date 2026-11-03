# Logistica_Setup.ps1 — instala el Portal de Logística "como app"
# Acceso en Escritorio + menú Inicio que abre en MODO APP (ventana propia, sin pestañas) con Chrome.
$ErrorActionPreference = 'Stop'
$Url = 'https://natural-trade-ltd.github.io/nt-logistica/'

function Get-Browser {
  $chrome = @("$Env:ProgramFiles\Google\Chrome\Application\chrome.exe",
              "${Env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
              "$Env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe") |
            Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $chrome) { $reg="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe"
    if (Test-Path $reg) { $p=(Get-ItemProperty $reg).'(default)'; if ($p -and (Test-Path $p)) { $chrome=$p } } }
  if ($chrome) { return $chrome }
  @("$Env:ProgramFiles\Microsoft\Edge\Application\msedge.exe","${Env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe") |
    Where-Object { Test-Path $_ } | Select-Object -First 1
}
$browser = Get-Browser
$eng = if ($browser) { Split-Path $browser -Leaf } else { 'navegador predeterminado' }

# icono salvia con "LOG" (Dueto Tierra); si falla, usa el del navegador
$icon = if ($browser) { "$browser,0" } else { '' }
try {
  Add-Type -AssemblyName System.Drawing
  $dir = Join-Path $Env:LOCALAPPDATA 'NT-Apps'; New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $ico = Join-Path $dir 'Logistica.ico'; $sz=128
  $bmp = New-Object System.Drawing.Bitmap $sz,$sz; $g=[System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'; $g.Clear([System.Drawing.Color]::Transparent)
  $pad=8;$d=$sz-2*$pad;$r=26;$gp=New-Object System.Drawing.Drawing2D.GraphicsPath
  $gp.AddArc($pad,$pad,$r,$r,180,90);$gp.AddArc($pad+$d-$r,$pad,$r,$r,270,90);$gp.AddArc($pad+$d-$r,$pad+$d-$r,$r,$r,0,90);$gp.AddArc($pad,$pad+$d-$r,$r,$r,90,90);$gp.CloseFigure()
  $g.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#587F6B'))),$gp)
  $font=New-Object System.Drawing.Font('Segoe UI',30,[System.Drawing.FontStyle]::Bold)
  $sf=New-Object System.Drawing.StringFormat;$sf.Alignment='Center';$sf.LineAlignment='Center'
  $g.DrawString('LOG',$font,(New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#F6FBF7'))),(New-Object System.Drawing.RectangleF 0,0,$sz,$sz),$sf)
  $g.Dispose();$hi=$bmp.GetHicon();$ic=[System.Drawing.Icon]::FromHandle($hi)
  $fs=[System.IO.File]::Create($ico);$ic.Save($fs);$fs.Close();$bmp.Dispose();$icon="$ico,0"
} catch { }

$w = New-Object -ComObject WScript.Shell
foreach($dir in @([Environment]::GetFolderPath('Desktop'), (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'))){
  try{
    $lnk = $w.CreateShortcut((Join-Path $dir 'Logistica NT-GF.lnk'))
    if($browser){ $lnk.TargetPath=$browser; $lnk.Arguments="--app=$Url"; if($icon){ $lnk.IconLocation=$icon } } else { $lnk.TargetPath=$Url }
    $lnk.Description='Portal de Logistica - NT/GF'
    $lnk.Save()
  }catch{}
}

Write-Host ''
Write-Host " Listo! El Portal de Logistica quedo como app en esta PC (motor: $eng)." -ForegroundColor Green
Write-Host '   - Icono "Logistica NT-GF" en tu Escritorio y en el menu Inicio (ventana propia).'
Write-Host ''
Write-Host ' Abriendo el portal para que inicies sesion con Google...' -ForegroundColor Green
if($browser){ Start-Process $browser -ArgumentList "--app=$Url" } else { Start-Process $Url }
Start-Sleep -Seconds 2
