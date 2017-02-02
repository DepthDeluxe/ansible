#!powershell
# This file is part of Ansible
#
# Copyright 2015, Peter Mounce <public@neverrunwithscissors.com>
# Michael Perzel <michaelperzel@gmail.com>
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

$ErrorActionPreference = "Stop"

# WANT_JSON
# POWERSHELL_COMMON

$params = Parse-Args $args;

$days_of_week = Get-AnsibleParam $params -name "days_of_week"
$interval = Get-Attr $params -name "interval" -default $null
$interval_unit = Get-Attr $params -name "interval_unit" -default minutes
$enabled = Get-AnsibleParam $params -name "enabled" -default $true
$enabled = $enabled | ConvertTo-Bool
$description = Get-AnsibleParam $params -name "description" -default " "
$path = Get-AnsibleParam $params -name "path" -type "path"
$argument = Get-AnsibleParam $params -name "argument"

$result = New-Object PSObject;
Set-Attr $result "changed" $false;

#Required vars
$name = Get-AnsibleParam -obj $params -name name -failifempty $true -resultobj $result
$state = Get-AnsibleParam -obj $params -name state -failifempty $true -resultobj $result -validateSet "present","absent"

#Vars conditionally required
$present_args_required = $state -eq "present"
$execute = Get-AnsibleParam -obj $params -name execute -failifempty $present_args_required  -resultobj $result
$frequency = Get-AnsibleParam -obj $params -name frequency -failifempty $present_args_required -resultobj $result
$time = Get-AnsibleParam -obj $params -name time -failifempty $present_args_required -resultobj $result
$user = Get-AnsibleParam -obj $params -name user -failifempty $present_args_required -resultobj $result


# Mandatory Vars
if ($frequency -eq "weekly")
{
    if (!($days_of_week))
    {
        Fail-Json $result "missing required argument: days_of_week"
    }
}
elseif ($frequency -eq "interval")
{
    if (!($interval))
    {
        Fail-Json $result "missing required argument: interval"
    }

    if ($interval_unit -ne "seconds" -and $interval_unit -ne "minutes" -and $interval_unit -ne "hours" -and $interval_unit -ne "days")
    {
        Fail-Json $result "argument interval_unit must be seconds, minutes, hours, or days"
    }
}

if ($path)
{
  $path = "\{0}\" -f $path
}
else
{
  $path = "\"  #default
}

try {
    $task = Get-ScheduledTask -TaskPath "$path" -TaskName "$name"

    # Correlate task state to enable variable, used to calculate if state needs to be changed
    $taskState = if ($task) { $task.State } else { $null }
    if ($taskState -eq "Ready"){
        $taskState = $true
    }
    elseif($taskState -eq "Disabled"){
        $taskState = $false
    }
    else
    {
        $taskState = $null
    }

    $measure = $task | measure
    if ($measure.count -eq 1 ) {
        $exists = $true
    }
    elseif ( ($measure.count -eq 0) -and ($state -eq "absent") ){
        Set-Attr $result "msg" "Task does not exist"
        Exit-Json $result
    }
    elseif ($measure.count -eq 0){
        $exists = $false
    }
    else {
        # This should never occur
        Fail-Json $result "$($measure.count) scheduled tasks found"
    }

    Set-Attr $result "exists" "$exists"

    if ($frequency){
        if ( $frequency -eq "interval"){
            $trigger = New-ScheduledTaskTrigger -Once -RepetitionInterval (iex $("new-timespan -$interval_unit $interval")) -At $time -RepetitionDuration ([timespan]::MaxValue)
        }
        elseif ( $frequency -eq "hourly"){
            $trigger = New-ScheduledTaskTrigger -Once -RepetitionInterval (new-timespan -hour 1) -At $time -RepetitionDuration ([timespan]::MaxValue)
        }
        elseif ($frequency -eq "daily") {
            $trigger =  New-ScheduledTaskTrigger -Daily -At $time
        }
        elseif ($frequency -eq "weekly"){
            $trigger =  New-ScheduledTaskTrigger -Weekly -At $time -DaysOfWeek $days_of_week
        }
        else {
            Fail-Json $result "frequency must be interval, hourly, daily or weekly"
        }
    }

    if ( ($state -eq "absent") -and ($exists -eq $true) ) {
        Unregister-ScheduledTask -TaskName $name -Confirm:$false
        $result.changed = $true
        Set-Attr $result "msg" "Deleted task $name"
        Exit-Json $result
    }
    elseif ( ($state -eq "absent") -and ($exists -eq $false) ) {
        Set-Attr $result "msg" "Task $name does not exist"
        Exit-Json $result
    }

    $principal = New-ScheduledTaskPrincipal -UserId "$user" -LogonType ServiceAccount

    if ($enabled -eq $false){
        $settings = New-ScheduledTaskSettingsSet -Disable
    }
    else {
        $settings = New-ScheduledTaskSettingsSet
    }

    if ($argument) {
        $action = New-ScheduledTaskAction -Execute $execute -Argument $argument
    }
    else {
        $action = New-ScheduledTaskAction -Execute $execute
    }

    if ( ($state -eq "present") -and ($exists -eq $false) ){
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $name -Description $description -TaskPath $path -Settings $settings -Principal $principal
        $task = Get-ScheduledTask -TaskName $name
        Set-Attr $result "msg" "Added new task $name"
        $result.changed = $true
    }
    elseif( ($state -eq "present") -and ($exists -eq $true) ) {
        Unregister-ScheduledTask -TaskName $name -Confirm:$false
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $name -Description $description -TaskPath $path -Settings $settings -Principal $principal
        Set-Attr $result "msg" "Updated task $name"
        $result.changed = $true
    }

    Exit-Json $result;
}
catch
{
  Fail-Json $result $_.Exception.Message
}
