function Show-Menu 
{ 
     param ( 
           [string]$Title = 'Deployment Menu' 
     ) 
     cls 
     Write-Host `n
     Write-Host "================ $Title ================" -ForegroundColor Green
     Write-Host `n     
     Write-Host "1: SSIS jobs deployment." 
     Write-Host "2: Data Archive Jobs deployment." 
     Write-Host "Q: Press 'Q' to quit." 
} 

do 
{ 
     Show-Menu 
     Write-Host `n
     $input = Read-Host "Please make a selection" 
     switch ($input) 
     { 
           '1' { 
                cls 
                .\ssis_job_deploy.ps1
           } '2' { 
                cls 
                .\archive_data_job_deploy.ps1
           } 'q' { 
                Write-Host "Exit." -ForegroundColor Green
                Write-Host `n
                return 
           } 
     } 
     pause 
} 
until ($input -eq 'q') 