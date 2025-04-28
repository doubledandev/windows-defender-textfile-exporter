# windows-defender-textfile-exporter
Windows defender textfile exporter to use with windows_exporter 

## Metrics

## `windows_textfile_defender_state`:  gauge
State of Windows Defender service
### Value
#### Windows >= 2016
- `1`: All protection enabled
- `0`: Some protection disabled
#### Windows < 2016
- `1`: Real Time Protection enabled
- `0`: Real Time Protection disabled

### Labels 
#### Windows >= 2016
- `engine_version`: Engine version
- `service_version`: Service version
- `real_time_protection_enabled`: Is real time protection enabled
- `antispyware_enabled`: Is antispyware enabled
- `antivirus_enabled`: Is antivirus enabled
- `on_access_protection_enabled`: Is on access protection enabled
- `behavior_monitor_enabled`: Is behavior monitoring enabled
- `ioav_enabled`: Is ioav protection enabled

#### Windows < 2016
- `engine_version`: Engine version
- `real_time_protection_enabled`: Is real time protection enabled


## `windows_textfile_defender_antivirus_state`:  gauge
State of Windows Defender Antivirus

### Value
#### Windows >= 2016
- `1`: Antivirus enabled
- `0`: Antivirus disabled
#### Windows < 2016
Always `1`, as Windows Defender Antivirus is always enabled when the Defender is enabled.
### Labels
- `signatures_age`: Age of the Virus signatures database
- `signatures_version`: Version of the Virus signatures database


## `windows_textfile_defender_antivirus_signature_last_update`:  gauge
### Value
Unix timestamp of the last update of the Virus signatures database
### Labels
- `signatures_age`: Age of the Virus signatures database
- `signatures_version`: Version of the Virus signatures database


## `windows_textfile_defender_antispyware_state`: gauge
State of Windows Defender Antispyware
### Value
#### Windows >= 2016
- `1`: Antispyware enabled
- `0`: Antispyware disabled
#### Windows < 2016
Always `1`, as Windows Defender Antispyware is always enabled when the Defender is enabled.
### Labels
- `signatures_age`: Age of the Spyware signatures database
- `signatures_version`: Version of the Spyware signatures database


## `windows_textfile_defender_antispyware_signature_last_update`: gauge
### Value
Unix timestamp of the last update of the Spyware signatures database
### Labels
- `signatures_age`: Age of the Spyware signatures database
- `signatures_version`: Version of the Spyware signatures database

## `textfile_collector_win_script_last_run_timestamp`: gauge
### Value
Unix timestamp of the last update of the script itself

## `textfile_collector_win_firewall_private_state`: gauge 
### Value
- `1`: enabled
- `0`: disabled

## `textfile_collector_win_firewall_domain_state`: gauge 
### Value
- `1`: enabled
- `0`: disabled

## `textfile_collector_win_firewall_public_state`: gauge 
### Value
- `1`: enabled
- `0`: disabled
