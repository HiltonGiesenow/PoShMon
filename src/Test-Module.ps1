<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.145
	 Created on:   	12/10/2017 2:39 AM
	 Created by:   	Jerris
	 Organization: 	
	 Filename:     	Test-Module.ps1
	===========================================================================
	.DESCRIPTION
	The Test-Module.ps1 script lets you test the functions and other features of
	your module in your PowerShell Studio module project. It's part of your project,
	but it is not included in your module.

	In this test script, import the module (be careful to import the correct version)
	and write commands that test the module features. You can include Pester
	tests, too.

	To run the script, click Run or Run in Console. Or, when working on any file
	in the project, click Home\Run or Home\Run in Console, or in the Project pane, 
	right-click the project name, and then click Run Project.
#>


#Explicitly import the module for testing
Import-Module 'PoShMon'
Import-Module 'Pester'

# Included for graceful deprication from Pester v3 - v4.
function Assert-VerifiableMocks
{
	[CmdletBinding()]
	param ()
	write-warning "This command has been renamed to 'Assert-VerifiableMock' (without the 's' at the end), please update your code. For more information see: https://github.com/pester/Pester/wiki/Migrating-from-Pester-3-to-Pester-4"
	Assert-VerifiableMock;
}

#Run each module function
Invoke-Expression -Command .\Tests\PoShMon.Tests.ps1

