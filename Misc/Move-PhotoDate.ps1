<# 
.SYNOPSIS 
   Move photos into a date folder based on EXIF Date Taken field

.DESCRIPTION
   Move photos to a folder in yyyy-MM-dd format, based on EXIF data.

.NOTES 
   File Name  : Move-PhotoDate.ps1
   Author     : John Sneddon
   Version    : 1.0.0
#>

param([string]$file)

function Get-TakenDate($file) 
{
   try 
   {
      $image = New-Object System.Drawing.Bitmap -ArgumentList $file
      $date = $image.GetPropertyItem(36867).Value
      $takenValue = [System.Text.Encoding]::Default.GetString($date, 0, $date.Length - 1)
      $date = [DateTime]::ParseExact($takenValue, 'yyyy:MM:dd HH:mm:ss', $null)
      $image.Dispose()
      if ($date -eq $null) {
         Write-Host '{ No ''Date Taken'' in Exif }' -ForegroundColor Cyan
         return  $null
      }
      return $date.ToString('yyyy-MM-dd')
   }
   catch 
   {
      return $null
   }
}

[Reflection.Assembly]::LoadFile('C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Drawing.dll') | Out-Null

gci *.jpg | foreach {
   Write-Host "$_`t->`t" -ForegroundColor Cyan -NoNewLine 
   
   $Date = Get-TakenDate( $_.FullName) 

   if ($Date)
   {
      $newDir = $_.DirectoryName +"\" + $date + "\" 
      
      if (-not (Test-Path $newDir))
      {
         New-Item -ItemType Directory $NewDir | Out-Null
      }
      Write-Host ($newDir+$_.Name) -ForegroundColor Cyan
      mv $_.FullName ($newDir+$_.Name)
   }
   else
   {
      Write-Host "No Date Found" -ForegroundColor Yellow
   }
}
