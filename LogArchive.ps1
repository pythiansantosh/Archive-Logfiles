#Script to move old logs to archive folder and remove files older than one month


#Defs (Note: Change to correct paths when using in Production)

$ErrorActionPreference='Stop'

$verboselogdate = $(Get-Date).ToString("yyyyMMddHHMMss")

$verboselog = "C:\Data\Celerion\Cleanup\$verboselogdate.log"

$logfolder = "C:\Data\Celerion\Cleanup"

$archivefolder = "C:\Data\Celerion\Cleanup\Archive"

$zipfile = "C:\Data\Celerion\Cleanup\Archive\$verboselogdate"

#Get Logs Older than a week
$logfilestomove = Get-ChildItem -Path $logfolder | Where-Object lastwritetime -LT $((Get-Date).AddDays(-8)) 

#Check and take action if log files are found
If($logfilestomove) {

Write-Output "Log files found older than 8 days" | Out-File $verboselog -Append
$logfilestomove | Out-File $verboselog -Append

    Foreach ($filetomove in $logfilestomove) {
        
        Try {
            $filetomove | Compress-Archive -DestinationPath $zipfile -Update
            Remove-Item -Path $filetomove.FullName -Force -Confirm:$false
            Write-Output "Archived $($filetomove.FullName) to $zipfile Archive" | Out-File $verboselog -Append
        }
        Catch {
        
            Write-Output "Error moving $($filetomove.FullName) to Archive Folder" | Out-File $verboselog -Append
        }
    }

}

Else {

Write-Output "Log files not found older than 8 days" | Out-File $verboselog -Append

}

#Clear Archive
#Find files in archive older than a month and delete them
$logfilestodelete = Get-ChildItem -Path $archivefolder | Where-Object lastwritetime -LT $((Get-Date).AddDays(-30))

#Check and take action if log files are found
If($logfilestodelete) {

Write-Output "Log files found older than 30 days" | Out-File $verboselog -Append
$logfilestodelete | Out-File $verboselog -Append

    Foreach ($filetodelete in $logfilestodelete) {
        
        Try {
            Remove-Item -Path $filetodelete.FullName -Force -Confirm:$false
            Write-Output "Removed $($filetodelete.FullName)" | Out-File $verboselog -Append
        }
        Catch {
        
            Write-Output "Error removing $($filetodelete.FullName)" | Out-File $verboselog -Append
        }
    }

}

Else {

Write-Output "Log files not found older than 30 days" | Out-File $verboselog -Append

}
