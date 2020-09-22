# RBAC Management Script
# Manages Role-Based Access Control assignments in Azure

param(
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName,
    
    [Parameter(Mandatory=$true)]
    [string]$RoleName,
    
    [Parameter(Mandatory=$false)]
    [string]$Scope = "/subscriptions/$(Get-AzContext).Subscription.Id",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Assign", "Remove", "List")]
    [string]$Action = "Assign"
)

# Connect to Azure
Connect-AzAccount -ErrorAction Stop

Write-Host "Managing RBAC assignments..." -ForegroundColor Green
Write-Host "User: $UserPrincipalName" -ForegroundColor Cyan
Write-Host "Role: $RoleName" -ForegroundColor Cyan
Write-Host "Scope: $Scope" -ForegroundColor Cyan

# Get user object
$User = Get-AzADUser -UserPrincipalName $UserPrincipalName -ErrorAction SilentlyContinue

if (-not $User) {
    Write-Error "User not found: $UserPrincipalName"
    exit 1
}

# Get role definition
$RoleDefinition = Get-AzRoleDefinition -Name $RoleName -ErrorAction SilentlyContinue

if (-not $RoleDefinition) {
    Write-Error "Role not found: $RoleName"
    exit 1
}

switch ($Action) {
    "Assign" {
        Write-Host "Assigning role..." -ForegroundColor Yellow
        
        # Check if assignment already exists
        $ExistingAssignment = Get-AzRoleAssignment `
            -ObjectId $User.Id `
            -RoleDefinitionName $RoleName `
            -Scope $Scope `
            -ErrorAction SilentlyContinue
        
        if ($ExistingAssignment) {
            Write-Warning "Role assignment already exists"
        } else {
            New-AzRoleAssignment `
                -ObjectId $User.Id `
                -RoleDefinitionName $RoleName `
                -Scope $Scope
            
            Write-Host "Role assigned successfully!" -ForegroundColor Green
        }
    }
    
    "Remove" {
        Write-Host "Removing role assignment..." -ForegroundColor Yellow
        
        $Assignment = Get-AzRoleAssignment `
            -ObjectId $User.Id `
            -RoleDefinitionName $RoleName `
            -Scope $Scope `
            -ErrorAction SilentlyContinue
        
        if ($Assignment) {
            Remove-AzRoleAssignment `
                -ObjectId $User.Id `
                -RoleDefinitionName $RoleName `
                -Scope $Scope
            
            Write-Host "Role assignment removed successfully!" -ForegroundColor Green
        } else {
            Write-Warning "Role assignment not found"
        }
    }
    
    "List" {
        Write-Host "Listing role assignments..." -ForegroundColor Yellow
        
        $Assignments = Get-AzRoleAssignment `
            -ObjectId $User.Id `
            -ErrorAction SilentlyContinue
        
        if ($Assignments) {
            $Assignments | Format-Table `
                RoleDefinitionName, `
                Scope, `
                @{Label="Principal"; Expression={$_.DisplayName}} `
                -AutoSize
        } else {
            Write-Host "No role assignments found" -ForegroundColor Yellow
        }
    }
}

Write-Host "RBAC management completed!" -ForegroundColor Green



























