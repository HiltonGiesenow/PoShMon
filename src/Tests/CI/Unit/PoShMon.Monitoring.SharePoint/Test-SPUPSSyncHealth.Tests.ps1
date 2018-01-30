$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-SPUPSSyncHealth" {
    InModuleScope PoShMon {

        class UpsServiceInstanceMock {
            [object]$Server

            UpsServiceInstanceMock ([string]$NewServerDisplayName) {
                $this.Server = [pscustomobject]@{DisplayName=$NewServerDisplayName};
            }
        }

        class FimRunHistoryItemMock {
            [string]$RunStatus
            [string]$RunStatusReturnValue
            [string]$RunStartTime

            FimRunHistoryItemMock ([string]$NewRunStatus, [string]$NewRunStartTime, [string]$NewRunStatusReturnValue) {
                $this.RunStatus = $NewRunStatus;
                $this.RunStartTime = $NewRunStartTime;
                $this.RunStatusReturnValue = $NewRunStatusReturnValue;
            }

            [object] RunDetails() {
                return [PSCustomObject]@{ "ReturnValue" = $this.RunStatusReturnValue }
            }
        }

        It "Should return a matching output structure" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                return @(
                    [UpsServiceInstanceMock]::new("Server1")
                )
            }

            Mock -CommandName Get-WmiObject -MockWith {
                $xml = '<?xml version="1.0" encoding="utf-16"?>
    <run-history>
     <run-details>
      <ma-id>{85098734-66BC-4938-8122-C5F585F463D0}</ma-id>
      <ma-name>MOSSAD-company</ma-name>
      <run-number>1879</run-number>
      <run-profile-name>DS_DELTAIMPORT</run-profile-name>
      <security-id>domain\serviceacc</security-id>
      <step-details step-number="2" step-id="{0D16BE50-FB6A-4CDC-B528-59B41D3F41A3}">
       <start-date>2017-01-04 23:00:55.253</start-date>
       <end-date>2017-01-04 23:00:58.987</end-date>
       <step-result>stopped-connectivity</step-result>
       <step-description>
        <step-type type="delta-import">
     <import-subtype>to-cs</import-subtype>
    </step-type>
    <partition>DC=ab,DC=company,DC=com</partition>
    <custom-data>
     <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
    </custom-data>
       </step-description>
       <current-export-step-counter>0</current-export-step-counter>
       <last-successful-export-step-counter>0</last-successful-export-step-counter>
       <ma-connection>
        <connection-result>failed-search</connection-result><server>DC01.ab.company.com:389</server><connection-log><incident><connection-result>success</connection-result><date>2017-01-04 23:00:58.473</date><server>DC01.ab.company.com:389</server></incident><incident><connection-result>failed-search</connection-result><date>2017-01-04 23:00:58.957</date><server>DC01.ab.company.com:389</server><cd-error><error-code>8453</error-code>
    <error-literal>Replication access was denied.</error-literal>
    <server-error-detail>00002105: LdapErr: DSID-adcv, comment: Error processing control, data 0, v1db1</server-error-detail>
    </cd-error></incident></connection-log>
       </ma-connection>
       <ma-discovery-errors>
       </ma-discovery-errors>
       <ma-discovery-counters>
       </ma-discovery-counters>
       <synchronization-errors/>
       <mv-retry-errors/>
       <staging-counters>
        <stage-no-change detail="false">0</stage-no-change>
        <stage-add detail="true">0</stage-add>
        <stage-update detail="true">0</stage-update>
        <stage-rename detail="true">0</stage-rename>
        <stage-delete detail="true">0</stage-delete>
        <stage-delete-add detail="true">0</stage-delete-add>
        <stage-failure detail="true">0</stage-failure>
       </staging-counters>
       <inbound-flow-counters>
        <disconnector-filtered detail="true">0</disconnector-filtered>
        <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
        <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
        <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
        <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
        <disconnector-projected-flow detail="true">0</disconnector-projected-flow>
        <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
        <disconnector-remains detail="false">0</disconnector-remains>
        <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
        <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
        <connector-flow detail="true">0</connector-flow>
        <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
        <connector-no-flow detail="true">0</connector-no-flow>
        <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
        <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
        <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
        <flow-failure detail="true">0</flow-failure>
       </inbound-flow-counters>
       <export-counters>
        <export-add detail="true">0</export-add>
        <export-update detail="true">0</export-update>
        <export-rename detail="true">0</export-rename>
        <export-delete detail="true">0</export-delete>
        <export-delete-add detail="true">0</export-delete-add>
        <export-failure detail="true">0</export-failure>
       </export-counters>
      </step-details>
      <step-details step-number="1" step-id="{874BEB73-FFF1-4C43-9836-26D8AACE454E}">
       <start-date>2017-01-04 23:00:35.380</start-date>
       <end-date>2017-01-04 23:00:55.223</end-date>
       <step-result>success</step-result>
       <step-description>
        <step-type type="delta-import">
     <import-subtype>to-cs</import-subtype>
    </step-type>
    <partition>DC=za,DC=company,DC=com</partition>
    <custom-data>
     <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
    </custom-data>
       </step-description>
       <current-export-step-counter>0</current-export-step-counter>
       <last-successful-export-step-counter>0</last-successful-export-step-counter>
       <ma-connection>
        <connection-result>success</connection-result><server>dc.company.com:389</server><connection-log><incident><connection-result>success</connection-result><date>2017-01-04 23:00:35.410</date><server>dc.company.com:389</server></incident></connection-log>
       </ma-connection>
       <ma-discovery-errors>
       </ma-discovery-errors>
       <ma-discovery-counters>
        <filtered-objects>46</filtered-objects>
       </ma-discovery-counters>
       <synchronization-errors/>
       <mv-retry-errors/>
       <staging-counters>
        <stage-no-change detail="false">0</stage-no-change>
        <stage-add detail="true">3</stage-add>
        <stage-update detail="true">27</stage-update>
        <stage-rename detail="true">2</stage-rename>
        <stage-delete detail="true">0</stage-delete>
        <stage-delete-add detail="true">0</stage-delete-add>
        <stage-failure detail="true">0</stage-failure>
       </staging-counters>
       <inbound-flow-counters>
        <disconnector-filtered detail="true">0</disconnector-filtered>
        <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
        <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
        <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
        <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
        <disconnector-projected-flow detail="true">0</disconnector-projected-flow>
        <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
        <disconnector-remains detail="false">0</disconnector-remains>
        <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
        <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
        <connector-flow detail="true">0</connector-flow>
        <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
        <connector-no-flow detail="true">0</connector-no-flow>
        <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
        <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
        <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
        <flow-failure detail="true">0</flow-failure>
       </inbound-flow-counters>
       <export-counters>
        <export-add detail="true">0</export-add>
        <export-update detail="true">0</export-update>
        <export-rename detail="true">0</export-rename>
        <export-delete detail="true">0</export-delete>
        <export-delete-add detail="true">0</export-delete-add>
        <export-failure detail="true">0</export-failure>
       </export-counters>
      </step-details>
     </run-details>
    </run-history>'

                return [FimRunHistoryItemMock]::new('not so good', (Get-Date).ToString(), $xml)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}   

            $actual = Test-SPUPSSyncHealth $poShMonConfiguration -WarningAction SilentlyContinue

            $headerKeyCount = 4

            $actual.Keys.Count | Should Be 6
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $actual.ContainsKey("HeaderUrl") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be $headerKeyCount
            $actual.OutputValues[1].ManagementAgent.Count | Should Be 0
            $actual.OutputValues[1].RunProfile.Count | Should Be 0
            $actual.OutputValues[1].RunStartTime.Count | Should Be 0
            $actual.OutputValues[1].ErrorDetail.Count | Should Be 0
            #$values1 = $actual.OutputValues[0]
            #$values1.Keys.Count | Should Be $headerKeyCount
            #$values1.ContainsKey("ManagementAgent") | Should Be $true
            #$values1.ContainsKey("RunProfile") | Should Be $true
            #$values1.ContainsKey("RunStartTime") | Should Be $true
            #$values1.ContainsKey("ErrorDetail") | Should Be $true
        }

        It "Should write the expected Verbose output" {
    
            Mock -CommandName Invoke-RemoteCommand -Verifiable -ModuleName PoShMon -MockWith {
                return @(
                    [UpsServiceInstanceMock]::new("Server1")
                )
            }

            Mock -CommandName Get-WmiObject -Verifiable -MockWith {
                $xml = '<?xml version="1.0" encoding="utf-16"?>
                                                        <run-history>
                                                         <run-details>
                                                          <ma-id>{12345678-66BC-4938-8122-C5F585F463D0}</ma-id>
                                                          <ma-name>MOSSAD-company</ma-name>
                                                          <run-number>1882</run-number>
                                                          <run-profile-name>DS_DELTASYNC</run-profile-name>
                                                          <security-id>Domain\ServiceAccount</security-id>
                                                          <step-details step-number="2" step-id="{12345678-A92D-4691-8C41-4526906B3307}">
                                                           <start-date>2017-01-04 23:05:00.303</start-date>
                                                           <end-date>2017-01-04 23:05:04.490</end-date>
                                                           <step-result>success</step-result>
                                                           <step-description>
                                                            <step-type type="apply-rules">
                                                         <apply-rules-subtype>apply-pending</apply-rules-subtype>
                                                        </step-type>
                                                        <partition>DC=ab,DC=company,DC=com</partition>
                                                        <custom-data>
                                                         <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
                                                        </custom-data>
                                                           </step-description>
                                                           <current-export-step-counter>0</current-export-step-counter>
                                                           <last-successful-export-step-counter>0</last-successful-export-step-counter>
                                                           <ma-connection>
                                                           </ma-connection>
                                                           <ma-discovery-errors>
                                                           </ma-discovery-errors>
                                                           <ma-discovery-counters>
                                                           </ma-discovery-counters>
                                                           <synchronization-errors/>
                                                           <mv-retry-errors/>
                                                           <staging-counters>
                                                            <stage-no-change detail="false">0</stage-no-change>
                                                            <stage-add detail="true">0</stage-add>
                                                            <stage-update detail="true">0</stage-update>
                                                            <stage-rename detail="true">0</stage-rename>
                                                            <stage-delete detail="true">0</stage-delete>
                                                            <stage-delete-add detail="true">0</stage-delete-add>
                                                            <stage-failure detail="true">0</stage-failure>
                                                           </staging-counters>
                                                           <inbound-flow-counters>
                                                            <disconnector-filtered detail="true">0</disconnector-filtered>
                                                            <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
                                                            <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
                                                            <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
                                                            <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
                                                            <disconnector-projected-flow detail="true">0</disconnector-projected-flow>
                                                            <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
                                                            <disconnector-remains detail="false">1023</disconnector-remains>
                                                            <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
                                                            <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
                                                            <connector-flow detail="true">0</connector-flow>
                                                            <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
                                                            <connector-no-flow detail="true">0</connector-no-flow>
                                                            <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
                                                            <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
                                                            <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
                                                            <flow-failure detail="true">0</flow-failure>
                                                           </inbound-flow-counters>
                                                           <export-counters>
                                                            <export-add detail="true">0</export-add>
                                                            <export-update detail="true">0</export-update>
                                                            <export-rename detail="true">0</export-rename>
                                                            <export-delete detail="true">0</export-delete>
                                                            <export-delete-add detail="true">0</export-delete-add>
                                                            <export-failure detail="true">0</export-failure>
                                                           </export-counters>
                                                          </step-details>
                                                          <step-details step-number="1" step-id="{12345678-E482-45D4-863A-DF382E82ED45}">
                                                           <start-date>2017-01-04 23:04:33.303</start-date>
                                                           <end-date>2017-01-04 23:04:59.977</end-date>
                                                           <step-result>success</step-result>
                                                           <step-description>
                                                            <step-type type="apply-rules">
                                                         <apply-rules-subtype>apply-pending</apply-rules-subtype>
                                                        </step-type>
                                                        <partition>DC=cd,DC=company,DC=com</partition>
                                                        <custom-data>
                                                         <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
                                                        </custom-data>
                                                           </step-description>
                                                           <current-export-step-counter>0</current-export-step-counter>
                                                           <last-successful-export-step-counter>0</last-successful-export-step-counter>
                                                           <ma-connection>
                                                           </ma-connection>
                                                           <ma-discovery-errors>
                                                           </ma-discovery-errors>
                                                           <ma-discovery-counters>
                                                           </ma-discovery-counters>
                                                           <synchronization-errors/>
                                                           <mv-retry-errors/>
                                                           <outbound-flow-counters ma="MOSS-UserProfile" ma-id="{12345678-4E0B-44DA-AF5F-62D4D99B2FBC}">
                                                         <provisioned-add-flow detail="true">3</provisioned-add-flow>
                                                         <connector-flow detail="true">23</connector-flow>
                                                        </outbound-flow-counters>
                                                           <staging-counters>
                                                            <stage-no-change detail="false">0</stage-no-change>
                                                            <stage-add detail="true">0</stage-add>
                                                            <stage-update detail="true">0</stage-update>
                                                            <stage-rename detail="true">0</stage-rename>
                                                            <stage-delete detail="true">0</stage-delete>
                                                            <stage-delete-add detail="true">0</stage-delete-add>
                                                            <stage-failure detail="true">0</stage-failure>
                                                           </staging-counters>
                                                           <inbound-flow-counters>
                                                            <disconnector-filtered detail="true">0</disconnector-filtered>
                                                            <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
                                                            <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
                                                            <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
                                                            <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
                                                            <disconnector-projected-flow detail="true">3</disconnector-projected-flow>
                                                            <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
                                                            <disconnector-remains detail="false">4235</disconnector-remains>
                                                            <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
                                                            <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
                                                            <connector-flow detail="true">23</connector-flow>
                                                            <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
                                                            <connector-no-flow detail="true">17</connector-no-flow>
                                                            <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
                                                            <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
                                                            <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
                                                            <flow-failure detail="true">0</flow-failure>
                                                           </inbound-flow-counters>
                                                           <export-counters>
                                                            <export-add detail="true">0</export-add>
                                                            <export-update detail="true">0</export-update>
                                                            <export-rename detail="true">0</export-rename>
                                                            <export-delete detail="true">0</export-delete>
                                                            <export-delete-add detail="true">0</export-delete-add>
                                                            <export-failure detail="true">0</export-failure>
                                                           </export-counters>
                                                          </step-details>
                                                         </run-details>
                                                        </run-history>'

                return [FimRunHistoryItemMock]::new('success', (Get-Date).ToString(), $xml)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}   

            $actual = Test-SPUPSSyncHealth $poShMonConfiguration -Verbose
            $output = $($actual = Test-SPUPSSyncHealth $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 4
            $output[0].ToString() | Should Be "Getting UPS Service App..."
            $output[1].ToString() | Should Be "Initiating 'User Profile Sync State' Test..."
            $output[2].ToString() | Should Be "`tGetting SharePoint service list to locate UPS Sync server..."
            $output[3].ToString() | Should Be "Complete 'User Profile Sync State' Test, Issues Found: No"
        }

        It "Should write the expected Warning output" {
    
            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                return @(
                    [UpsServiceInstanceMock]::new("Server1")
                )
            }

            Mock -CommandName Get-WmiObject -MockWith {
                $xml = '<?xml version="1.0" encoding="utf-16"?>
    <run-history>
     <run-details>
      <ma-id>{85098734-66BC-4938-8122-C5F585F463D0}</ma-id>
      <ma-name>MOSSAD-company</ma-name>
      <run-number>1879</run-number>
      <run-profile-name>DS_DELTAIMPORT</run-profile-name>
      <security-id>domain\serviceacc</security-id>
      <step-details step-number="2" step-id="{0D16BE50-FB6A-4CDC-B528-59B41D3F41A3}">
       <start-date>2017-01-04 23:00:55.253</start-date>
       <end-date>2017-01-04 23:00:58.987</end-date>
       <step-result>stopped-connectivity</step-result>
       <step-description>
        <step-type type="delta-import">
     <import-subtype>to-cs</import-subtype>
    </step-type>
    <partition>DC=ab,DC=company,DC=com</partition>
    <custom-data>
     <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
    </custom-data>
       </step-description>
       <current-export-step-counter>0</current-export-step-counter>
       <last-successful-export-step-counter>0</last-successful-export-step-counter>
       <ma-connection>
        <connection-result>failed-search</connection-result><server>DC01.ab.company.com:389</server><connection-log><incident><connection-result>success</connection-result><date>2017-01-04 23:00:58.473</date><server>DC01.ab.company.com:389</server></incident><incident><connection-result>failed-search</connection-result><date>2017-01-04 23:00:58.957</date><server>DC01.ab.company.com:389</server><cd-error><error-code>8453</error-code>
    <error-literal>Replication access was denied.</error-literal>
    <server-error-detail>00002105: LdapErr: DSID-adcv, comment: Error processing control, data 0, v1db1</server-error-detail>
    </cd-error></incident></connection-log>
       </ma-connection>
       <ma-discovery-errors>
       </ma-discovery-errors>
       <ma-discovery-counters>
       </ma-discovery-counters>
       <synchronization-errors/>
       <mv-retry-errors/>
       <staging-counters>
        <stage-no-change detail="false">0</stage-no-change>
        <stage-add detail="true">0</stage-add>
        <stage-update detail="true">0</stage-update>
        <stage-rename detail="true">0</stage-rename>
        <stage-delete detail="true">0</stage-delete>
        <stage-delete-add detail="true">0</stage-delete-add>
        <stage-failure detail="true">0</stage-failure>
       </staging-counters>
       <inbound-flow-counters>
        <disconnector-filtered detail="true">0</disconnector-filtered>
        <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
        <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
        <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
        <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
        <disconnector-projected-flow detail="true">0</disconnector-projected-flow>
        <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
        <disconnector-remains detail="false">0</disconnector-remains>
        <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
        <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
        <connector-flow detail="true">0</connector-flow>
        <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
        <connector-no-flow detail="true">0</connector-no-flow>
        <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
        <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
        <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
        <flow-failure detail="true">0</flow-failure>
       </inbound-flow-counters>
       <export-counters>
        <export-add detail="true">0</export-add>
        <export-update detail="true">0</export-update>
        <export-rename detail="true">0</export-rename>
        <export-delete detail="true">0</export-delete>
        <export-delete-add detail="true">0</export-delete-add>
        <export-failure detail="true">0</export-failure>
       </export-counters>
      </step-details>
      <step-details step-number="1" step-id="{874BEB73-FFF1-4C43-9836-26D8AACE454E}">
       <start-date>2017-01-04 23:00:35.380</start-date>
       <end-date>2017-01-04 23:00:55.223</end-date>
       <step-result>success</step-result>
       <step-description>
        <step-type type="delta-import">
     <import-subtype>to-cs</import-subtype>
    </step-type>
    <partition>DC=za,DC=company,DC=com</partition>
    <custom-data>
     <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
    </custom-data>
       </step-description>
       <current-export-step-counter>0</current-export-step-counter>
       <last-successful-export-step-counter>0</last-successful-export-step-counter>
       <ma-connection>
        <connection-result>success</connection-result><server>dc.company.com:389</server><connection-log><incident><connection-result>success</connection-result><date>2017-01-04 23:00:35.410</date><server>dc.company.com:389</server></incident></connection-log>
       </ma-connection>
       <ma-discovery-errors>
       </ma-discovery-errors>
       <ma-discovery-counters>
        <filtered-objects>46</filtered-objects>
       </ma-discovery-counters>
       <synchronization-errors/>
       <mv-retry-errors/>
       <staging-counters>
        <stage-no-change detail="false">0</stage-no-change>
        <stage-add detail="true">3</stage-add>
        <stage-update detail="true">27</stage-update>
        <stage-rename detail="true">2</stage-rename>
        <stage-delete detail="true">0</stage-delete>
        <stage-delete-add detail="true">0</stage-delete-add>
        <stage-failure detail="true">0</stage-failure>
       </staging-counters>
       <inbound-flow-counters>
        <disconnector-filtered detail="true">0</disconnector-filtered>
        <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
        <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
        <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
        <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
        <disconnector-projected-flow detail="true">0</disconnector-projected-flow>
        <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
        <disconnector-remains detail="false">0</disconnector-remains>
        <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
        <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
        <connector-flow detail="true">0</connector-flow>
        <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
        <connector-no-flow detail="true">0</connector-no-flow>
        <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
        <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
        <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
        <flow-failure detail="true">0</flow-failure>
       </inbound-flow-counters>
       <export-counters>
        <export-add detail="true">0</export-add>
        <export-update detail="true">0</export-update>
        <export-rename detail="true">0</export-rename>
        <export-delete detail="true">0</export-delete>
        <export-delete-add detail="true">0</export-delete-add>
        <export-failure detail="true">0</export-failure>
       </export-counters>
      </step-details>
     </run-details>
    </run-history>'

                return [FimRunHistoryItemMock]::new('not so good', (Get-Date).ToString(), $xml)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}   

            $actual = Test-SPUPSSyncHealth $poShMonConfiguration
            $output = $($actual = Test-SPUPSSyncHealth $poShMonConfiguration) 3>&1

            $output.Count | Should Be 1
            $output[0].ToString().Substring(0, 97) | Should Be "`tStep 2 has status of stopped-connectivity : <connection-result>failed-search</connection-result>"
        }

        It "Should not warn on no failed Jobs" {
    
            Mock -CommandName Invoke-RemoteCommand -Verifiable -ModuleName PoShMon -MockWith {
                return @(
                    [UpsServiceInstanceMock]::new("Server1")
                )
            }

            Mock -CommandName Get-WmiObject -Verifiable -MockWith {
                $xml = '<?xml version="1.0" encoding="utf-16"?>
                                                        <run-history>
                                                         <run-details>
                                                          <ma-id>{12345678-66BC-4938-8122-C5F585F463D0}</ma-id>
                                                          <ma-name>MOSSAD-company</ma-name>
                                                          <run-number>1882</run-number>
                                                          <run-profile-name>DS_DELTASYNC</run-profile-name>
                                                          <security-id>Domain\ServiceAccount</security-id>
                                                          <step-details step-number="2" step-id="{12345678-A92D-4691-8C41-4526906B3307}">
                                                           <start-date>2017-01-04 23:05:00.303</start-date>
                                                           <end-date>2017-01-04 23:05:04.490</end-date>
                                                           <step-result>success</step-result>
                                                           <step-description>
                                                            <step-type type="apply-rules">
                                                         <apply-rules-subtype>apply-pending</apply-rules-subtype>
                                                        </step-type>
                                                        <partition>DC=ab,DC=company,DC=com</partition>
                                                        <custom-data>
                                                         <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
                                                        </custom-data>
                                                           </step-description>
                                                           <current-export-step-counter>0</current-export-step-counter>
                                                           <last-successful-export-step-counter>0</last-successful-export-step-counter>
                                                           <ma-connection>
                                                           </ma-connection>
                                                           <ma-discovery-errors>
                                                           </ma-discovery-errors>
                                                           <ma-discovery-counters>
                                                           </ma-discovery-counters>
                                                           <synchronization-errors/>
                                                           <mv-retry-errors/>
                                                           <staging-counters>
                                                            <stage-no-change detail="false">0</stage-no-change>
                                                            <stage-add detail="true">0</stage-add>
                                                            <stage-update detail="true">0</stage-update>
                                                            <stage-rename detail="true">0</stage-rename>
                                                            <stage-delete detail="true">0</stage-delete>
                                                            <stage-delete-add detail="true">0</stage-delete-add>
                                                            <stage-failure detail="true">0</stage-failure>
                                                           </staging-counters>
                                                           <inbound-flow-counters>
                                                            <disconnector-filtered detail="true">0</disconnector-filtered>
                                                            <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
                                                            <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
                                                            <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
                                                            <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
                                                            <disconnector-projected-flow detail="true">0</disconnector-projected-flow>
                                                            <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
                                                            <disconnector-remains detail="false">1023</disconnector-remains>
                                                            <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
                                                            <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
                                                            <connector-flow detail="true">0</connector-flow>
                                                            <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
                                                            <connector-no-flow detail="true">0</connector-no-flow>
                                                            <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
                                                            <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
                                                            <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
                                                            <flow-failure detail="true">0</flow-failure>
                                                           </inbound-flow-counters>
                                                           <export-counters>
                                                            <export-add detail="true">0</export-add>
                                                            <export-update detail="true">0</export-update>
                                                            <export-rename detail="true">0</export-rename>
                                                            <export-delete detail="true">0</export-delete>
                                                            <export-delete-add detail="true">0</export-delete-add>
                                                            <export-failure detail="true">0</export-failure>
                                                           </export-counters>
                                                          </step-details>
                                                          <step-details step-number="1" step-id="{12345678-E482-45D4-863A-DF382E82ED45}">
                                                           <start-date>2017-01-04 23:04:33.303</start-date>
                                                           <end-date>2017-01-04 23:04:59.977</end-date>
                                                           <step-result>success</step-result>
                                                           <step-description>
                                                            <step-type type="apply-rules">
                                                         <apply-rules-subtype>apply-pending</apply-rules-subtype>
                                                        </step-type>
                                                        <partition>DC=cd,DC=company,DC=com</partition>
                                                        <custom-data>
                                                         <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
                                                        </custom-data>
                                                           </step-description>
                                                           <current-export-step-counter>0</current-export-step-counter>
                                                           <last-successful-export-step-counter>0</last-successful-export-step-counter>
                                                           <ma-connection>
                                                           </ma-connection>
                                                           <ma-discovery-errors>
                                                           </ma-discovery-errors>
                                                           <ma-discovery-counters>
                                                           </ma-discovery-counters>
                                                           <synchronization-errors/>
                                                           <mv-retry-errors/>
                                                           <outbound-flow-counters ma="MOSS-UserProfile" ma-id="{12345678-4E0B-44DA-AF5F-62D4D99B2FBC}">
                                                         <provisioned-add-flow detail="true">3</provisioned-add-flow>
                                                         <connector-flow detail="true">23</connector-flow>
                                                        </outbound-flow-counters>
                                                           <staging-counters>
                                                            <stage-no-change detail="false">0</stage-no-change>
                                                            <stage-add detail="true">0</stage-add>
                                                            <stage-update detail="true">0</stage-update>
                                                            <stage-rename detail="true">0</stage-rename>
                                                            <stage-delete detail="true">0</stage-delete>
                                                            <stage-delete-add detail="true">0</stage-delete-add>
                                                            <stage-failure detail="true">0</stage-failure>
                                                           </staging-counters>
                                                           <inbound-flow-counters>
                                                            <disconnector-filtered detail="true">0</disconnector-filtered>
                                                            <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
                                                            <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
                                                            <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
                                                            <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
                                                            <disconnector-projected-flow detail="true">3</disconnector-projected-flow>
                                                            <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
                                                            <disconnector-remains detail="false">4235</disconnector-remains>
                                                            <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
                                                            <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
                                                            <connector-flow detail="true">23</connector-flow>
                                                            <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
                                                            <connector-no-flow detail="true">17</connector-no-flow>
                                                            <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
                                                            <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
                                                            <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
                                                            <flow-failure detail="true">0</flow-failure>
                                                           </inbound-flow-counters>
                                                           <export-counters>
                                                            <export-add detail="true">0</export-add>
                                                            <export-update detail="true">0</export-update>
                                                            <export-rename detail="true">0</export-rename>
                                                            <export-delete detail="true">0</export-delete>
                                                            <export-delete-add detail="true">0</export-delete-add>
                                                            <export-failure detail="true">0</export-failure>
                                                           </export-counters>
                                                          </step-details>
                                                         </run-details>
                                                        </run-history>'

                return [FimRunHistoryItemMock]::new('success', (Get-Date).ToString(), $xml)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}   

            $actual = Test-SPUPSSyncHealth $poShMonConfiguration
        
            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $true
        }

        It "Should warn on any failed Jobs" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                return @(
                    [UpsServiceInstanceMock]::new("Server1")
                )
            }

            Mock -CommandName Get-WmiObject -MockWith {
                $xml = '<?xml version="1.0" encoding="utf-16"?>
    <run-history>
     <run-details>
      <ma-id>{85098734-66BC-4938-8122-C5F585F463D0}</ma-id>
      <ma-name>MOSSAD-company</ma-name>
      <run-number>1879</run-number>
      <run-profile-name>DS_DELTAIMPORT</run-profile-name>
      <security-id>domain\serviceacc</security-id>
      <step-details step-number="2" step-id="{0D16BE50-FB6A-4CDC-B528-59B41D3F41A3}">
       <start-date>2017-01-04 23:00:55.253</start-date>
       <end-date>2017-01-04 23:00:58.987</end-date>
       <step-result>stopped-connectivity</step-result>
       <step-description>
        <step-type type="delta-import">
     <import-subtype>to-cs</import-subtype>
    </step-type>
    <partition>DC=ab,DC=company,DC=com</partition>
    <custom-data>
     <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
    </custom-data>
       </step-description>
       <current-export-step-counter>0</current-export-step-counter>
       <last-successful-export-step-counter>0</last-successful-export-step-counter>
       <ma-connection>
        <connection-result>failed-search</connection-result><server>DC01.ab.company.com:389</server><connection-log><incident><connection-result>success</connection-result><date>2017-01-04 23:00:58.473</date><server>DC01.ab.company.com:389</server></incident><incident><connection-result>failed-search</connection-result><date>2017-01-04 23:00:58.957</date><server>DC01.ab.company.com:389</server><cd-error><error-code>8453</error-code>
    <error-literal>Replication access was denied.</error-literal>
    <server-error-detail>00002105: LdapErr: DSID-adcv, comment: Error processing control, data 0, v1db1</server-error-detail>
    </cd-error></incident></connection-log>
       </ma-connection>
       <ma-discovery-errors>
       </ma-discovery-errors>
       <ma-discovery-counters>
       </ma-discovery-counters>
       <synchronization-errors/>
       <mv-retry-errors/>
       <staging-counters>
        <stage-no-change detail="false">0</stage-no-change>
        <stage-add detail="true">0</stage-add>
        <stage-update detail="true">0</stage-update>
        <stage-rename detail="true">0</stage-rename>
        <stage-delete detail="true">0</stage-delete>
        <stage-delete-add detail="true">0</stage-delete-add>
        <stage-failure detail="true">0</stage-failure>
       </staging-counters>
       <inbound-flow-counters>
        <disconnector-filtered detail="true">0</disconnector-filtered>
        <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
        <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
        <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
        <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
        <disconnector-projected-flow detail="true">0</disconnector-projected-flow>
        <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
        <disconnector-remains detail="false">0</disconnector-remains>
        <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
        <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
        <connector-flow detail="true">0</connector-flow>
        <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
        <connector-no-flow detail="true">0</connector-no-flow>
        <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
        <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
        <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
        <flow-failure detail="true">0</flow-failure>
       </inbound-flow-counters>
       <export-counters>
        <export-add detail="true">0</export-add>
        <export-update detail="true">0</export-update>
        <export-rename detail="true">0</export-rename>
        <export-delete detail="true">0</export-delete>
        <export-delete-add detail="true">0</export-delete-add>
        <export-failure detail="true">0</export-failure>
       </export-counters>
      </step-details>
      <step-details step-number="1" step-id="{874BEB73-FFF1-4C43-9836-26D8AACE454E}">
       <start-date>2017-01-04 23:00:35.380</start-date>
       <end-date>2017-01-04 23:00:55.223</end-date>
       <step-result>success</step-result>
       <step-description>
        <step-type type="delta-import">
     <import-subtype>to-cs</import-subtype>
    </step-type>
    <partition>DC=za,DC=company,DC=com</partition>
    <custom-data>
     <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
    </custom-data>
       </step-description>
       <current-export-step-counter>0</current-export-step-counter>
       <last-successful-export-step-counter>0</last-successful-export-step-counter>
       <ma-connection>
        <connection-result>success</connection-result><server>dc.company.com:389</server><connection-log><incident><connection-result>success</connection-result><date>2017-01-04 23:00:35.410</date><server>dc.company.com:389</server></incident></connection-log>
       </ma-connection>
       <ma-discovery-errors>
       </ma-discovery-errors>
       <ma-discovery-counters>
        <filtered-objects>46</filtered-objects>
       </ma-discovery-counters>
       <synchronization-errors/>
       <mv-retry-errors/>
       <staging-counters>
        <stage-no-change detail="false">0</stage-no-change>
        <stage-add detail="true">3</stage-add>
        <stage-update detail="true">27</stage-update>
        <stage-rename detail="true">2</stage-rename>
        <stage-delete detail="true">0</stage-delete>
        <stage-delete-add detail="true">0</stage-delete-add>
        <stage-failure detail="true">0</stage-failure>
       </staging-counters>
       <inbound-flow-counters>
        <disconnector-filtered detail="true">0</disconnector-filtered>
        <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
        <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
        <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
        <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
        <disconnector-projected-flow detail="true">0</disconnector-projected-flow>
        <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
        <disconnector-remains detail="false">0</disconnector-remains>
        <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
        <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
        <connector-flow detail="true">0</connector-flow>
        <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
        <connector-no-flow detail="true">0</connector-no-flow>
        <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
        <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
        <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
        <flow-failure detail="true">0</flow-failure>
       </inbound-flow-counters>
       <export-counters>
        <export-add detail="true">0</export-add>
        <export-update detail="true">0</export-update>
        <export-rename detail="true">0</export-rename>
        <export-delete detail="true">0</export-delete>
        <export-delete-add detail="true">0</export-delete-add>
        <export-failure detail="true">0</export-failure>
       </export-counters>
      </step-details>
     </run-details>
    </run-history>'

                return [FimRunHistoryItemMock]::new('not so good', (Get-Date).ToString(), $xml)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}   

            $actual = Test-SPUPSSyncHealth $poShMonConfiguration -WarningAction SilentlyContinue
        
            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 1
        }

        It "Should return all failed Jobs" {

            Mock -CommandName Invoke-RemoteCommand -ModuleName PoShMon -MockWith {
                return @(
                    [UpsServiceInstanceMock]::new("Server1")
                )
            }

            Mock -CommandName Get-WmiObject -MockWith {
                $jobs =  @()

                $xml = '<?xml version="1.0" encoding="utf-16"?>
                                                        <run-history>
                                                         <run-details>
                                                          <ma-id>{12345678-66BC-4938-8122-C5F585F463D0}</ma-id>
                                                          <ma-name>MOSSAD-company</ma-name>
                                                          <run-number>1882</run-number>
                                                          <run-profile-name>DS_DELTASYNC</run-profile-name>
                                                          <security-id>Domain\ServiceAccount</security-id>
                                                          <step-details step-number="2" step-id="{12345678-A92D-4691-8C41-4526906B3307}">
                                                           <start-date>2017-01-04 23:05:00.303</start-date>
                                                           <end-date>2017-01-04 23:05:04.490</end-date>
                                                           <step-result>success</step-result>
                                                           <step-description>
                                                            <step-type type="apply-rules">
                                                         <apply-rules-subtype>apply-pending</apply-rules-subtype>
                                                        </step-type>
                                                        <partition>DC=ab,DC=company,DC=com</partition>
                                                        <custom-data>
                                                         <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
                                                        </custom-data>
                                                           </step-description>
                                                           <current-export-step-counter>0</current-export-step-counter>
                                                           <last-successful-export-step-counter>0</last-successful-export-step-counter>
                                                           <ma-connection>
                                                           </ma-connection>
                                                           <ma-discovery-errors>
                                                           </ma-discovery-errors>
                                                           <ma-discovery-counters>
                                                           </ma-discovery-counters>
                                                           <synchronization-errors/>
                                                           <mv-retry-errors/>
                                                           <staging-counters>
                                                            <stage-no-change detail="false">0</stage-no-change>
                                                            <stage-add detail="true">0</stage-add>
                                                            <stage-update detail="true">0</stage-update>
                                                            <stage-rename detail="true">0</stage-rename>
                                                            <stage-delete detail="true">0</stage-delete>
                                                            <stage-delete-add detail="true">0</stage-delete-add>
                                                            <stage-failure detail="true">0</stage-failure>
                                                           </staging-counters>
                                                           <inbound-flow-counters>
                                                            <disconnector-filtered detail="true">0</disconnector-filtered>
                                                            <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
                                                            <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
                                                            <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
                                                            <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
                                                            <disconnector-projected-flow detail="true">0</disconnector-projected-flow>
                                                            <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
                                                            <disconnector-remains detail="false">1023</disconnector-remains>
                                                            <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
                                                            <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
                                                            <connector-flow detail="true">0</connector-flow>
                                                            <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
                                                            <connector-no-flow detail="true">0</connector-no-flow>
                                                            <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
                                                            <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
                                                            <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
                                                            <flow-failure detail="true">0</flow-failure>
                                                           </inbound-flow-counters>
                                                           <export-counters>
                                                            <export-add detail="true">0</export-add>
                                                            <export-update detail="true">0</export-update>
                                                            <export-rename detail="true">0</export-rename>
                                                            <export-delete detail="true">0</export-delete>
                                                            <export-delete-add detail="true">0</export-delete-add>
                                                            <export-failure detail="true">0</export-failure>
                                                           </export-counters>
                                                          </step-details>
                                                          <step-details step-number="1" step-id="{12345678-E482-45D4-863A-DF382E82ED45}">
                                                           <start-date>2017-01-04 23:04:33.303</start-date>
                                                           <end-date>2017-01-04 23:04:59.977</end-date>
                                                           <step-result>success</step-result>
                                                           <step-description>
                                                            <step-type type="apply-rules">
                                                         <apply-rules-subtype>apply-pending</apply-rules-subtype>
                                                        </step-type>
                                                        <partition>DC=cd,DC=company,DC=com</partition>
                                                        <custom-data>
                                                         <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
                                                        </custom-data>
                                                           </step-description>
                                                           <current-export-step-counter>0</current-export-step-counter>
                                                           <last-successful-export-step-counter>0</last-successful-export-step-counter>
                                                           <ma-connection>
                                                           </ma-connection>
                                                           <ma-discovery-errors>
                                                           </ma-discovery-errors>
                                                           <ma-discovery-counters>
                                                           </ma-discovery-counters>
                                                           <synchronization-errors/>
                                                           <mv-retry-errors/>
                                                           <outbound-flow-counters ma="MOSS-UserProfile" ma-id="{12345678-4E0B-44DA-AF5F-62D4D99B2FBC}">
                                                         <provisioned-add-flow detail="true">3</provisioned-add-flow>
                                                         <connector-flow detail="true">23</connector-flow>
                                                        </outbound-flow-counters>
                                                           <staging-counters>
                                                            <stage-no-change detail="false">0</stage-no-change>
                                                            <stage-add detail="true">0</stage-add>
                                                            <stage-update detail="true">0</stage-update>
                                                            <stage-rename detail="true">0</stage-rename>
                                                            <stage-delete detail="true">0</stage-delete>
                                                            <stage-delete-add detail="true">0</stage-delete-add>
                                                            <stage-failure detail="true">0</stage-failure>
                                                           </staging-counters>
                                                           <inbound-flow-counters>
                                                            <disconnector-filtered detail="true">0</disconnector-filtered>
                                                            <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
                                                            <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
                                                            <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
                                                            <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
                                                            <disconnector-projected-flow detail="true">3</disconnector-projected-flow>
                                                            <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
                                                            <disconnector-remains detail="false">4235</disconnector-remains>
                                                            <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
                                                            <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
                                                            <connector-flow detail="true">23</connector-flow>
                                                            <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
                                                            <connector-no-flow detail="true">17</connector-no-flow>
                                                            <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
                                                            <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
                                                            <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
                                                            <flow-failure detail="true">0</flow-failure>
                                                           </inbound-flow-counters>
                                                           <export-counters>
                                                            <export-add detail="true">0</export-add>
                                                            <export-update detail="true">0</export-update>
                                                            <export-rename detail="true">0</export-rename>
                                                            <export-delete detail="true">0</export-delete>
                                                            <export-delete-add detail="true">0</export-delete-add>
                                                            <export-failure detail="true">0</export-failure>
                                                           </export-counters>
                                                          </step-details>
                                                         </run-details>
                                                        </run-history>'
                $jobs += [FimRunHistoryItemMock]::new('success', (Get-Date).ToString(), $xml)

                $xml = '<?xml version="1.0" encoding="utf-16"?>
    <run-history>
     <run-details>
      <ma-id>{85098734-66BC-4938-8122-C5F585F463D0}</ma-id>
      <ma-name>MOSSAD-company</ma-name>
      <run-number>1879</run-number>
      <run-profile-name>DS_DELTAIMPORT</run-profile-name>
      <security-id>domain\serviceacc</security-id>
      <step-details step-number="2" step-id="{0D16BE50-FB6A-4CDC-B528-59B41D3F41A3}">
       <start-date>2017-01-04 23:00:55.253</start-date>
       <end-date>2017-01-04 23:00:58.987</end-date>
       <step-result>stopped-connectivity</step-result>
       <step-description>
        <step-type type="delta-import">
     <import-subtype>to-cs</import-subtype>
    </step-type>
    <partition>DC=ab,DC=company,DC=com</partition>
    <custom-data>
     <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
    </custom-data>
       </step-description>
       <current-export-step-counter>0</current-export-step-counter>
       <last-successful-export-step-counter>0</last-successful-export-step-counter>
       <ma-connection>
        <connection-result>failed-search</connection-result><server>DC01.ab.company.com:389</server><connection-log><incident><connection-result>success</connection-result><date>2017-01-04 23:00:58.473</date><server>DC01.ab.company.com:389</server></incident><incident><connection-result>failed-search</connection-result><date>2017-01-04 23:00:58.957</date><server>DC01.ab.company.com:389</server><cd-error><error-code>8453</error-code>
    <error-literal>Replication access was denied.</error-literal>
    <server-error-detail>00002105: LdapErr: DSID-adcv, comment: Error processing control, data 0, v1db1</server-error-detail>
    </cd-error></incident></connection-log>
       </ma-connection>
       <ma-discovery-errors>
       </ma-discovery-errors>
       <ma-discovery-counters>
       </ma-discovery-counters>
       <synchronization-errors/>
       <mv-retry-errors/>
       <staging-counters>
        <stage-no-change detail="false">0</stage-no-change>
        <stage-add detail="true">0</stage-add>
        <stage-update detail="true">0</stage-update>
        <stage-rename detail="true">0</stage-rename>
        <stage-delete detail="true">0</stage-delete>
        <stage-delete-add detail="true">0</stage-delete-add>
        <stage-failure detail="true">0</stage-failure>
       </staging-counters>
       <inbound-flow-counters>
        <disconnector-filtered detail="true">0</disconnector-filtered>
        <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
        <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
        <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
        <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
        <disconnector-projected-flow detail="true">0</disconnector-projected-flow>
        <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
        <disconnector-remains detail="false">0</disconnector-remains>
        <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
        <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
        <connector-flow detail="true">0</connector-flow>
        <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
        <connector-no-flow detail="true">0</connector-no-flow>
        <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
        <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
        <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
        <flow-failure detail="true">0</flow-failure>
       </inbound-flow-counters>
       <export-counters>
        <export-add detail="true">0</export-add>
        <export-update detail="true">0</export-update>
        <export-rename detail="true">0</export-rename>
        <export-delete detail="true">0</export-delete>
        <export-delete-add detail="true">0</export-delete-add>
        <export-failure detail="true">0</export-failure>
       </export-counters>
      </step-details>
      <step-details step-number="1" step-id="{874BEB73-FFF1-4C43-9836-26D8AACE454E}">
       <start-date>2017-01-04 23:00:35.380</start-date>
       <end-date>2017-01-04 23:00:55.223</end-date>
       <step-result>success</step-result>
       <step-description>
        <step-type type="delta-import">
     <import-subtype>to-cs</import-subtype>
    </step-type>
    <partition>DC=za,DC=company,DC=com</partition>
    <custom-data>
     <adma-step-data><batch-size>100</batch-size><page-size>500</page-size><time-limit>120</time-limit></adma-step-data>
    </custom-data>
       </step-description>
       <current-export-step-counter>0</current-export-step-counter>
       <last-successful-export-step-counter>0</last-successful-export-step-counter>
       <ma-connection>
        <connection-result>success</connection-result><server>dc.company.com:389</server><connection-log><incident><connection-result>success</connection-result><date>2017-01-04 23:00:35.410</date><server>dc.company.com:389</server></incident></connection-log>
       </ma-connection>
       <ma-discovery-errors>
       </ma-discovery-errors>
       <ma-discovery-counters>
        <filtered-objects>46</filtered-objects>
       </ma-discovery-counters>
       <synchronization-errors/>
       <mv-retry-errors/>
       <staging-counters>
        <stage-no-change detail="false">0</stage-no-change>
        <stage-add detail="true">3</stage-add>
        <stage-update detail="true">27</stage-update>
        <stage-rename detail="true">2</stage-rename>
        <stage-delete detail="true">0</stage-delete>
        <stage-delete-add detail="true">0</stage-delete-add>
        <stage-failure detail="true">0</stage-failure>
       </staging-counters>
       <inbound-flow-counters>
        <disconnector-filtered detail="true">0</disconnector-filtered>
        <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
        <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
        <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
        <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
        <disconnector-projected-flow detail="true">0</disconnector-projected-flow>
        <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
        <disconnector-remains detail="false">0</disconnector-remains>
        <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
        <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
        <connector-flow detail="true">0</connector-flow>
        <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
        <connector-no-flow detail="true">0</connector-no-flow>
        <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
        <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
        <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
        <flow-failure detail="true">0</flow-failure>
       </inbound-flow-counters>
       <export-counters>
        <export-add detail="true">0</export-add>
        <export-update detail="true">0</export-update>
        <export-rename detail="true">0</export-rename>
        <export-delete detail="true">0</export-delete>
        <export-delete-add detail="true">0</export-delete-add>
        <export-failure detail="true">0</export-failure>
       </export-counters>
      </step-details>
     </run-details>
    </run-history>'
                $jobs += [FimRunHistoryItemMock]::new('not so good', (Get-Date).ToString(), $xml)

                $xml = '<?xml version="1.0" encoding="utf-16"?>
    <run-history>
     <run-details>
      <ma-id>{FB0D00E1-4E0B-44DA-AF5F-62D4D99B2FBC}</ma-id>
      <ma-name>MOSS-UserProfile</ma-name>
      <run-number>2590</run-number>
      <run-profile-name>MOSS_EXPORT_a9061a90-5fb2-485e-90e8-4019c5c1f9ce</run-profile-name>
      <security-id>domain\serviceacc</security-id>
      <step-details step-number="1" step-id="{E0446E50-FF59-4691-9EC0-F9BD3D564F4A}">
       <start-date>2017-01-04 23:05:05.367</start-date>
       <end-date>2017-01-04 23:06:06.677</end-date>
       <step-result>completed-export-errors</step-result>
       <step-description>
        <step-type type="export">
    </step-type>
    <partition>default</partition>
    <custom-data>
     <run-config><input-file /><timeout>0</timeout></run-config>
    </custom-data>
       </step-description>
       <current-export-step-counter>0</current-export-step-counter>
       <last-successful-export-step-counter>0</last-successful-export-step-counter>
       <ma-connection>
       </ma-connection>
       <ma-discovery-errors>
       </ma-discovery-errors>
       <ma-discovery-counters>
       </ma-discovery-counters>
       <synchronization-errors><export-error cs-guid="{12345678-DF83-E611-8CE8-00505689546C}" dn="MVID=67d2da90-0c2a-e411-a2e8-0050568e45d6">
     <date-occurred>2017-01-04 23:06:02.006</date-occurred>
     <first-occurred>2016-09-26 12:02:16.987</first-occurred>
     <retry-count>77</retry-count>
     <error-type>ma-extension-error</error-type>
     <cd-error>
      <error-code>0x80230703</error-code><error-literal>System.Reflection.TargetInvocationException: Exception has been thrown by the target of an invocation. ---&gt; System.AggregateException: One 
    or more errors occurred. ---&gt; Microsoft.Office.Server.UserProfiles.PropertyInvalidFormatException: Invalid URL Format: Invalid format for a URL. ---&gt; System.UriFormatException: Invalid URI
    : The format of the URI could not be determined.
       at System.Uri.CreateThis(String uri, Boolean dontEscape, UriKind uriKind)
       at Microsoft.Office.Server.UserProfiles.UserProfileGlobal.ValidatedUrl(Object value)
       --- End of inner exception stack trace ---
       at Microsoft.Office.Server.UserProfiles.UserProfileGlobal.ValidatedUrl(Object value)
       at Microsoft.Office.Server.UserProfiles.MemberGroup.set_Url(String value)
       at Microsoft.Office.Server.UserProfiles.MemberGroup.BulkPropertiesUpdate(Int64 importExportId, Hashtable properties, String sourceReference)
       at Microsoft.Office.Server.UserProfiles.ProfileImportExportService.&lt;&gt;c__DisplayClass26.&lt;UpdateWithProfileChangeData&gt;b__24(Int32 idx)
       at System.Threading.Tasks.Parallel.&lt;&gt;c__DisplayClassf`1.&lt;ForWorker&gt;b__c()
       at System.Threading.Tasks.Task.InnerInvokeWithArg(Task childTask)
       at System.Threading.Tasks.Task.&lt;&gt;c__DisplayClass11.&lt;ExecuteSelfReplicating&gt;b__10(Object param0)
       --- End of inner exception stack trace ---
       at System.Threading.Tasks.Task.Wait(Int32 millisecondsTimeout, CancellationToken cancellationToken)
       at System.Threading.Tasks.Task.Wait()
       at System.Threading.Tasks.Parallel.ForWorker[TLocal](Int32 fromInclusive, Int32 toExclusive, ParallelOptions parallelOptions, Action`1 body, Action`2 bodyWithState, Func`4 bodyWithLocal, Func
    `1 localInit, Action`1 localFinally)
       at System.Threading.Tasks.Parallel.For(Int32 fromInclusive, Int32 toExclusive, ParallelOptions parallelOptions, Action`1 body)
       at Microsoft.Office.Server.UserProfiles.ProfileImportExportService.UpdateWithProfileChangeData(Int64 importExportId, ProfileChangeData[] profileChangeData)
       --- End of inner exception stack trace ---
       at System.RuntimeMethodHandle.InvokeMethod(Object target, Object[] arguments, Signature sig, Boolean constructor)
       at System.Reflection.RuntimeMethodInfo.UnsafeInvokeInternal(Object obj, Object[] parameters, Object[] arguments)
       at System.Reflection.RuntimeMethodInfo.Invoke(Object obj, BindingFlags invokeAttr, Binder binder, Object[] parameters, CultureInfo culture)
       at Microsoft.Office.Server.WebServiceDirectProxy.WebMethodInfo.Invoke(Object webServiceInstance, Object[] args)
       at Microsoft.Office.Server.WebServiceDirectProxy.Invoke(String methodName, Object[] args)
       at Microsoft.Office.Server.UserProfiles.ManagementAgent.ProfileImportExportDirect.UpdateWithProfileChangeData(Int64 importExportId, ProfileChangeData[] profileChangeData)
       at Microsoft.Office.Server.UserProfiles.ManagementAgent.ProfileImportExportExtension.Microsoft.MetadirectoryServices.IMAExtensibleCallExport.ExportEntry(ModificationType modificationType, Str
    ing[] changedAttributes, CSEntry csentry)
    </error-literal>
     </cd-error>
    </export-error>
    </synchronization-errors>
       <mv-retry-errors/>
       <staging-counters>
        <stage-no-change detail="false">0</stage-no-change>
        <stage-add detail="true">0</stage-add>
        <stage-update detail="true">0</stage-update>
        <stage-rename detail="true">0</stage-rename>
        <stage-delete detail="true">0</stage-delete>
        <stage-delete-add detail="true">0</stage-delete-add>
        <stage-failure detail="true">0</stage-failure>
       </staging-counters>
       <inbound-flow-counters>
        <disconnector-filtered detail="true">0</disconnector-filtered>
        <disconnector-joined-no-flow detail="true">0</disconnector-joined-no-flow>
        <disconnector-joined-flow detail="true">0</disconnector-joined-flow>
        <disconnector-joined-remove-mv detail="true">0</disconnector-joined-remove-mv>
        <disconnector-projected-no-flow detail="true">0</disconnector-projected-no-flow>
        <disconnector-projected-flow detail="true">0</disconnector-projected-flow>
        <disconnector-projected-remove-mv detail="true">0</disconnector-projected-remove-mv>
        <disconnector-remains detail="false">0</disconnector-remains>
        <connector-filtered-remove-mv detail="true">0</connector-filtered-remove-mv>
        <connector-filtered-leave-mv detail="true">0</connector-filtered-leave-mv>
        <connector-flow detail="true">0</connector-flow>
        <connector-flow-remove-mv detail="true">0</connector-flow-remove-mv>
        <connector-no-flow detail="true">0</connector-no-flow>
        <connector-delete-remove-mv detail="true">0</connector-delete-remove-mv>
        <connector-delete-leave-mv detail="true">0</connector-delete-leave-mv>
        <connector-delete-add-processed detail="true">0</connector-delete-add-processed>
        <flow-failure detail="true">0</flow-failure>
       </inbound-flow-counters>
       <export-counters>
        <export-add detail="true">3</export-add>
        <export-update detail="true">23</export-update>
        <export-rename detail="true">0</export-rename>
        <export-delete detail="true">0</export-delete>
        <export-delete-add detail="true">0</export-delete-add>
        <export-failure detail="true">1</export-failure>
       </export-counters>
      </step-details>
     </run-details>
    </run-history>'
                $jobs += [FimRunHistoryItemMock]::new('failed again', (Get-Date).ToString(), $xml)

                return $jobs
            }

            $poShMonConfiguration = New-PoShMonConfiguration {}   

            $actual = Test-SPUPSSyncHealth $poShMonConfiguration -WarningAction SilentlyContinue
        
            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $false

            $actual.OutputValues.Count | Should Be 2
        }

    }
}