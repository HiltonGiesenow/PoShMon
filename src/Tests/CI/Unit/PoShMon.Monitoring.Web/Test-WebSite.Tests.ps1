$rootPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ('..\..\..\..\') -Resolve
Remove-Module PoShMon -ErrorAction SilentlyContinue
Import-Module (Join-Path $rootPath -ChildPath "PoShMon.psd1")

Describe "Test-Website" {
    InModuleScope PoShMon {

        class WebRequestMock {
            [int]$StatusCode
            [string]$StatusDescription
            [string]$Content

            WebRequestMock ([int]$NewStatusCode, [String]$NewStatusDescription, [String]$NewContent) {
                $this.StatusCode = $NewStatusCode;
                $this.StatusDescription = $NewStatusDescription;
                $this.Content = $NewContent;
            }
        }

        class RemoteWebRequestMock {
            [int]$StatusCode
            [string]$StatusDescription
            [string]$Content
            [string]$ServerName

            RemoteWebRequestMock ([int]$NewStatusCode, [String]$NewStatusDescription, [String]$NewContent, [String]$NewServerName) {
                $this.StatusCode = $NewStatusCode;
                $this.StatusDescription = $NewStatusDescription;
                $this.Content = $NewContent;
                $this.ServerName = $NewServerName;
            }
        }

        It "Should return a matching output structure" {
    
            Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
                return [WebRequestMock]::new(200, "OK", "Some Text")
            }
            Mock -CommandName Invoke-RemoteWebRequest -Verifiable -ModuleName PoShMon -MockWith {
                return [RemoteWebRequestMock]::new(200, "OK", "Some Text", $serverName)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                    General `
                        -ServerNames 'Server1','Server2'
                    WebSite `
                        -WebsiteDetails @{
                                            "http://my.website.com" = "Some Text"
                                         }
                }

            $actual = Test-WebSites $poShMonConfiguration

            Assert-VerifiableMock

            $actual.Keys.Count | Should Be 5
            $actual.ContainsKey("NoIssuesFound") | Should Be $true
            $actual.ContainsKey("OutputHeaders") | Should Be $true
            $actual.ContainsKey("OutputValues") | Should Be $true
            $actual.ContainsKey("SectionHeader") | Should Be $true
            $actual.ContainsKey("ElapsedTime") | Should Be $true
            $headers = $actual.OutputHeaders
            $headers.Keys.Count | Should Be 3
            $actual.OutputValues[1].ServerName | Should Be 'Server1'
            $actual.OutputValues[1].StatusCode | Should Be 200
            $actual.OutputValues[1].Outcome | Should Be 'Specified Page Content Found'
            $actual.OutputValues[1].Highlight.Count | Should Be 0
            #$values1 = $actual.OutputValues[0]
            #$values1.Keys.Count | Should Be 4
            #$values1.ContainsKey("ServerName") | Should Be $true
            #$values1.ContainsKey("StatusCode") | Should Be $true
            #$values1.ContainsKey("Outcome") | Should Be $true
            #$values1.ContainsKey("Highlight") | Should Be $true
        }

        It "Should write the expected Verbose output" {

            Mock -CommandName Invoke-WebRequest -MockWith {
                return [WebRequestMock]::new(200, "OK", "Some Text")
            }
            Mock -CommandName Invoke-RemoteWebRequest -ModuleName PoShMon -MockWith {
                return [RemoteWebRequestMock]::new(200, "OK", "Some Text", $serverName)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                    General `
                        -ServerNames 'Server1','Server2'
                    WebSite `
                        -WebsiteDetails @{
                                            "http://my.website.com" = "Some Text"
                                         }
                }

            $actual = Test-WebSites $poShMonConfiguration -Verbose
            $output = $($actual = Test-WebSites $poShMonConfiguration -Verbose) 4>&1

            $output.Count | Should Be 8
            $output[0].ToString() | Should Be "Initiating 'Web Test - http://my.website.com' Test..."
            $output[1].ToString() | Should Be "`tScanning Site http://my.website.com (Direct)"
            $output[2].ToString() | Should Be "`t`t(Direct) : 200 : Specified Page Content Found"
            $output[3].ToString() | Should Be "`tScanning Site http://my.website.com on Server1"
            $output[4].ToString() | Should Be "`t`tServer1 : 200 : Specified Page Content Found"
            $output[5].ToString() | Should Be "`tScanning Site http://my.website.com on Server2"
            $output[6].ToString() | Should Be "`t`tServer2 : 200 : Specified Page Content Found"
            $output[7].ToString() | Should Be "Complete 'Web Test - http://my.website.com' Test, Issues Found: No"
        }

        It "Should test directly and on each server" {

            Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
                return [WebRequestMock]::new(200, "OK", "Some Text")
            }
            Mock -CommandName Invoke-RemoteWebRequest -ModuleName PoShMon -Verifiable -MockWith {
                return [RemoteWebRequestMock]::new(200, "OK", "Some Text", $serverName)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                    General `
                        -ServerNames 'Server1','Server2'
                    WebSite `
                        -WebsiteDetails @{
                                            "http://my.website.com" = "Some Text"
                                         }
                }

            $actual = Test-WebSites $poShMonConfiguration

            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $true
            $actual.OutputValues.Count | Should Be 3
            $actual.OutputValues[0].ServerName | Should Be '(Direct)'
            $actual.OutputValues[1].ServerName | Should Be 'Server1'
            $actual.OutputValues[2].ServerName | Should Be 'Server2'
        }

        It "Should fail on server 1" {

            Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
                return [WebRequestMock]::new('200', '<html>Test Content</html>', 'OK')
            }

            Mock -CommandName Invoke-RemoteWebRequest -ModuleName PoShMon -Verifiable -MockWith {
                if ($ServerName -ne "Server1")
                    { return [RemoteWebRequestMock]::new('200', 'OK', '<html>Test Content</html>', $ServerName) }
                else
                    { return [RemoteWebRequestMock]::new('500', 'Server Error', '<html><title>Server Error</title></html>', $ServerName) }
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                    General `
                        -ServerNames 'Server1','Server2'
                    WebSite `
                        -WebsiteDetails @{
                                            "http://my.website.com" = "Test Content"
                                         }
                }

            $actual = Test-WebSites $poShMonConfiguration

            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $false
            $actual.OutputValues[1].Highlight | Should Be 'Outcome'
            $actual.OutputValues[1].Outcome | Should Be 'Server Error'
        }
    
        It "Should find matching text" {

            Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
                return [WebRequestMock]::new('200', 'OK', '<html>Test Content</html>')
            }

            Mock -CommandName Invoke-RemoteWebRequest -ModuleName PoShMon -Verifiable -MockWith {
                if ($ServerName -eq "Server1")
                    { return [RemoteWebRequestMock]::new('200', 'OK', '<html>Test Content</html>', $ServerName) }
                else
                    { return [RemoteWebRequestMock]::new('200', 'OK', '<html>other stuff</html>', $ServerName) }
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                    General `
                        -ServerNames 'Server1','Server2'
                    WebSite `
                        -WebsiteDetails @{
                                            "http://my.website.com" = "Test Content"
                                         }
                }

            $actual = Test-WebSites $poShMonConfiguration

            Assert-VerifiableMock

            $actual.NoIssuesFound | Should Be $false
            $actual.OutputValues[0].Highlight.Count | Should Be 0
            $actual.OutputValues[0].Outcome | Should Be 'Specified Page Content Found'
            $actual.OutputValues[1].Highlight.Count | Should Be 0
            $actual.OutputValues[1].Outcome | Should Be 'Specified Page Content Found'
            $actual.OutputValues[2].Highlight | Should Be 'Outcome'
            $actual.OutputValues[2].Outcome | Should Be 'Specified Page Content Not Found'
		}
	}
}
Describe "Test-Website-NewScope" {
    InModuleScope PoShMon {
		It "Should test Direct on local server (if run locally) and remotely on others" {

            Mock -CommandName Invoke-WebRequest -MockWith  {
                return [WebRequestMock]::new(200, "OK", "Some Text")
            }
            Mock -CommandName Invoke-RemoteWebRequest -ModuleName PoShMon -MockWith {
                return [RemoteWebRequestMock]::new(200, "OK", "Some Text", $serverName)
            }

            $poShMonConfiguration = New-PoShMonConfiguration {
                    General `
                        -ServerNames $env:COMPUTERNAME,'Server2','Server3'
                    WebSite `
                        -WebsiteDetails @{
                                            "http://my.website.com" = "Some Text"
                                         }
                }

            $actual = Test-WebSites $poShMonConfiguration

            $actual.NoIssuesFound | Should Be $true
            $actual.OutputValues.Count | Should Be 3
            $actual.OutputValues[0].ServerName | Should Be '(Direct)'
			$actual.OutputValues[1].ServerName | Should Be 'Server2'
			$actual.OutputValues[2].ServerName | Should Be 'Server3'
			
			Assert-MockCalled -CommandName Invoke-WebRequest -Times 1 -Exactly
			Assert-MockCalled -CommandName Invoke-RemoteWebRequest -Times 2 -Exactly 
		}
    }
}
Describe "Test-Website-NewScope2" {
    InModuleScope PoShMon {

        class WebRequestMock {
            [int]$StatusCode
            [string]$StatusDescription
            [string]$Content

            WebRequestMock ([int]$NewStatusCode, [String]$NewStatusDescription, [String]$NewContent) {
                $this.StatusCode = $NewStatusCode;
                $this.StatusDescription = $NewStatusDescription;
                $this.Content = $NewContent;
            }
        }

        class RemoteWebRequestMock {
            [int]$StatusCode
            [string]$StatusDescription
            [string]$Content
            [string]$ServerName

            RemoteWebRequestMock ([int]$NewStatusCode, [String]$NewStatusDescription, [String]$NewContent, [String]$NewServerName) {
                $this.StatusCode = $NewStatusCode;
                $this.StatusDescription = $NewStatusDescription;
                $this.Content = $NewContent;
                $this.ServerName = $NewServerName;
            }
        }

        Mock -CommandName Invoke-WebRequest -MockWith  {
            return [WebRequestMock]::new(200, "OK", "Some Text")
        }
        Mock -CommandName Invoke-RemoteWebRequest -ModuleName PoShMon -MockWith {
            return [RemoteWebRequestMock]::new(200, "OK", "Some Text", $serverName)
        }

		It "Should test Direct on local server and stop if no other servers" {

            $poShMonConfiguration = New-PoShMonConfiguration {
                    General `
                        -ServerNames $env:COMPUTERNAME
                    WebSite `
                        -WebsiteDetails @{
                                            "http://my.website.com" = "Some Text"
                                         }
                }

            $actual = Test-WebSites $poShMonConfiguration

            $actual.NoIssuesFound | Should Be $true
            $actual.OutputValues.Count | Should Be 1
            $actual.OutputValues[0].ServerName | Should Be '(Direct)'
			
			Assert-MockCalled -CommandName Invoke-WebRequest -Times 1 -Exactly
			Assert-MockCalled -CommandName Invoke-RemoteWebRequest -Times 0 -Exactly 
        }
	}
}
	Describe "Test-Website-NewScope3" {
		InModuleScope PoShMon {
	
			class WebRequestMock {
				[int]$StatusCode
				[string]$StatusDescription
				[string]$Content
	
				WebRequestMock ([int]$NewStatusCode, [String]$NewStatusDescription, [String]$NewContent) {
					$this.StatusCode = $NewStatusCode;
					$this.StatusDescription = $NewStatusDescription;
					$this.Content = $NewContent;
				}
			}
	
			class RemoteWebRequestMock {
				[int]$StatusCode
				[string]$StatusDescription
				[string]$Content
				[string]$ServerName
	
				RemoteWebRequestMock ([int]$NewStatusCode, [String]$NewStatusDescription, [String]$NewContent, [String]$NewServerName) {
					$this.StatusCode = $NewStatusCode;
					$this.StatusDescription = $NewStatusDescription;
					$this.Content = $NewContent;
					$this.ServerName = $NewServerName;
				}
			}
	
			Mock -CommandName Invoke-WebRequest -MockWith  {
				return [WebRequestMock]::new(200, "OK", "Some Text")
			}
			Mock -CommandName Invoke-RemoteWebRequest -ModuleName PoShMon -MockWith {
				return [RemoteWebRequestMock]::new(200, "OK", "Some Text", $serverName)
			}
	
			It "Should test Direct on local server correctly for just one more server" {
	
				$poShMonConfiguration = New-PoShMonConfiguration {
						General `
							-ServerNames $env:COMPUTERNAME,'Server2'
						WebSite `
							-WebsiteDetails @{
												"http://my.website.com" = "Some Text"
											 }
					}
	
				$actual = Test-WebSites $poShMonConfiguration
	
				$actual.NoIssuesFound | Should Be $true
				$actual.OutputValues.Count | Should Be 2
				$actual.OutputValues[0].ServerName | Should Be '(Direct)'
				$actual.OutputValues[1].ServerName | Should Be 'Server2'
				
				Assert-MockCalled -CommandName Invoke-WebRequest -Times 1 -Exactly
				Assert-MockCalled -CommandName Invoke-RemoteWebRequest -ParameterFilter { $ServerName -eq 'Server2' } -Times 1 -Exactly 
			}
		}
}