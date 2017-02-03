#!powershell
# This file is part of Ansible
#
# Copyright 2017 Colin Heinzmann <colin@heinzmann.me>
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

$result = @{
  changed = $false
}

$params = Parse-Args $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false

$server = Get-AnsibleParam $params -name "server" -failifempty $true -resultobj $result
$enabled = Get-AnsibleParam $params -name "enabled" -type "bool" -failifempty $true -resultobj $result

# convert to integer for reg setting
if ($enabled) {
  $enabled = 1
} else {
  $enabled = 0
}

try {
  $reg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
  $settings = Get-ItemProperty -Path "$reg"

  if ($settings.ProxyServer -eq $server -and $settings.ProxyEnable -eq $enabled) {
    $result.msg = "Proxy settings unchanged"
  } else {
    if ($check_mode -ne $true) {
      Set-ItemProperty -Path $reg -Name ProxyServer -Value "$server"
      Set-ItemProperty -Path $reg -Name ProxyEnable -Value $enabled
    }

    $result.changed = $true
    $result.msg = "Updated proxy settings"
  }

  Exit-Json $result
} catch {
  Fail-Json $result $_.Exception.Message
}
