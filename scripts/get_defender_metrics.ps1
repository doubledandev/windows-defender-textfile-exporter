# Description: This script is used to get Windows Defender metrics and write them to a file for Prometheus to scrape.

Function Convert-ToUnixDate ($PSdate) {
   $epoch = [timezone]::CurrentTimeZone.ToLocalTime([datetime]'1/1/1970')
   (New-TimeSpan -Start $epoch -End $PSdate).TotalSeconds
}

Function Enabled-ToInt ($Enabled) {
   if ($Enabled) {
      return 1
   }
   return 0
}

$currentTimestamp = [int](Convert-ToUnixDate (Get-Date))

$defender_state = Get-MpComputerStatus
$antispyware_enabled = Enabled-ToInt($defender_state.AntispywareEnabled)
$antivirus_enabled = Enabled-ToInt($defender_state.AntivirusEnabled)
$antivirus_signatures_age = Convert-ToUnixDate($defender_state.AntispywareSignatureLastUpdated)
$antispyware_signatures_age = Convert-ToUnixDate($defender_state.AntivirusSignatureLastUpdated)
$ioav_enabled = Enabled-ToInt($defender_state.IoavProtectionEnabled)
$behavior_monitor_enabled = Enabled-ToInt($defender_state.BehaviorMonitorEnabled)
$on_access_protection_enabled = Enabled-ToInt($defender_state.OnAccessProtectionEnabled)
$real_time_protection_enabled = Enabled-ToInt($defender_state.RealTimeProtectionEnabled)

$defender_enabled = Enabled-ToInt($defender_state.AntispywareEnabled -and $defender_state.AntivirusEnabled -and $defender_state.RealTimeProtectionEnabled -and $defender_state.BehaviorMonitorEnabled -and $defender_state.OnAccessProtectionEnabled -and $defender_state.IoavProtectionEnabled)

$firewallProfiles = Get-NetFirewallProfile -ErrorAction Stop
$firewallDomainEnabled = if ($firewallProfiles | Where-Object { $_.Name -eq "Domain" } | Select-Object -ExpandProperty Enabled) { 1 } else { 0 }
$firewallPrivateEnabled = if ($firewallProfiles | Where-Object { $_.Name -eq "Private" } | Select-Object -ExpandProperty Enabled) { 1 } else { 0 }
$firewallPublicEnabled = if ($firewallProfiles | Where-Object { $_.Name -eq "Public" } | Select-Object -ExpandProperty Enabled) { 1 } else { 0 }

# Metric to indicate state of Windows Defender
# Label to indicate the state and version of the Windows Defender engine, Service and Signatures and antispyware signatures age
$metrics = "# HELP textfile_collector_win_defender_state Windows Defender State
# TYPE textfile_collector_win_defender_state gauge
textfile_collector_win_defender_state{engine_version=`"$($defender_state.AMEngineVersion)`",service_version=`"$($defender_state.AMServiceVersion)`",antivirus_enabled=`"$antivirus_enabled`",antispyware_enabled=`"$antispyware_enabled`", behavior_monitor_enabled=`"$behavior_monitor_enabled`", ioav_enabled=`"$ioav_enabled`", on_access_protection_enabled=`"$on_access_protection_enabled`", real_time_protection_enabled=`"$real_time_protection_enabled`"} $defender_enabled
"

# Metric for Antivirus state with signatures version, age and last updated
$metrics += "# HELP textfile_collector_win_defender_antivirus_state Windows Defender Antivirus State
# TYPE textfile_collector_win_defender_antivirus_state gauge
textfile_collector_win_defender_antivirus_state{signatures_age=`"$($defender_state.AntivirusSignatureAge)`",signatures_version=`"$($defender_state.AntivirusSignatureVersion)`"} $antivirus_enabled
# HELP textfile_collector_win_defender_antivirus_signature_last_update Windows Defender Antivirus Signatures Last Update
# TYPE textfile_collector_win_defender_antivirus_signature_last_update gauge
textfile_collector_win_defender_antivirus_signature_last_update{signatures_age=`"$($defender_state.AntivirusSignatureAge)`",signatures_version=`"$($defender_state.AntivirusSignatureVersion)`"} $antivirus_signatures_age
"

# Metric for Antispyware state with signatures version, age and last updated
$metrics += "# HELP textfile_collector_win_defender_antispyware_state Windows Defender Antispyware State
# TYPE textfile_collector_win_defender_antispyware_state gauge
textfile_collector_win_defender_antispyware_state{signatures_age=`"$($defender_state.AntispywareSignatureAge)`",signatures_version=`"$($defender_state.AntispywareSignatureVersion)`"} $antispyware_enabled
# HELP textfile_collector_win_defender_antispyware_signature_last_update Windows Defender Antispyware Signatures Last Update
# TYPE textfile_collector_win_defender_antispyware_signature_last_update gauge
textfile_collector_win_defender_antispyware_signature_last_update{signatures_age=`"$($defender_state.AntispywareSignatureAge)`",signatures_version=`"$($defender_state.AntispywareSignatureVersion)`"} $antispyware_signatures_age
"

# Metric for Firewall state (Domain, Private and Public)
$metrics += "# HELP textfile_collector_win_firewall_domain_state Windows Firewall Domain Profile State 1 - Enabled / 0 - Disabled
# TYPE textfile_collector_win_firewall_domain_state gauge
textfile_collector_win_firewall_domain_state $firewallDomainEnabled
"
$metrics += "# HELP textfile_collector_win_firewall_private_state Windows Firewall Domain Profile State 1 - Enabled / 0 - Disabled
# TYPE textfile_collector_win_firewall_private_state gauge
textfile_collector_win_firewall_private_state $firewallPrivateEnabled
"
$metrics += "# HELP textfile_collector_win_firewall_public_state Windows Firewall Domain Profile State 1 - Enabled / 0 - Disabled
# TYPE textfile_collector_win_firewall_public_state gauge
textfile_collector_win_firewall_public_state $firewallPublicEnabled
"

$metrics += "# HELP textfile_collector_win_script_last_run_timestamp Unix timestamp of last successful script run
# TYPE textfile_collector_win_script_last_run_timestamp gauge
textfile_collector_win_script_last_run_timestamp $currentTimestamp
"

[System.IO.File]::WriteAllText("C:\Prometheus\textfile_inputs\defender_metrics.prom",$metrics,[System.Text.Encoding]::ASCII)
