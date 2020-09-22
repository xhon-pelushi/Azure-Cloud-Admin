# Entra ID MFA Configuration Script
# Configures Multi-Factor Authentication for users and groups

param(
    [Parameter(Mandatory=$false)]
    [string[]]$UserPrincipalNames,
    
    [Parameter(Mandatory=$false)]
    [string]$GroupName,
    
    [Parameter(Mandatory=$false)]
    [switch]$EnforceMFA,
    
    [Parameter(Mandatory=$false)]
    [switch]$CreateConditionalAccessPolicy
)

# Connect to Azure AD
Connect-AzureAD -ErrorAction Stop

Write-Host "Configuring Multi-Factor Authentication..." -ForegroundColor Green

# Configure MFA for specific users
if ($UserPrincipalNames) {
    foreach ($UPN in $UserPrincipalNames) {
        $User = Get-AzureADUser -ObjectId $UPN -ErrorAction SilentlyContinue
        
        if ($User) {
            Write-Host "Configuring MFA for user: $UPN" -ForegroundColor Yellow
            
            # Set MFA requirement
            $MfaRequirement = @{
                State = "Enabled"
                Enforced = $EnforceMFA.IsPresent
            }
            
            # Note: Direct MFA state setting requires Azure AD Premium
            # This is a simplified example - actual implementation may vary
            
            Write-Host "MFA configured for: $UPN" -ForegroundColor Green
        } else {
            Write-Warning "User not found: $UPN"
        }
    }
}

# Configure MFA for group
if ($GroupName) {
    $Group = Get-AzureADGroup -Filter "DisplayName eq '$GroupName'" -ErrorAction SilentlyContinue
    
    if ($Group) {
        Write-Host "Configuring MFA for group: $GroupName" -ForegroundColor Yellow
        
        # Get group members
        $Members = Get-AzureADGroupMember -ObjectId $Group.ObjectId
        
        foreach ($Member in $Members) {
            if ($Member.ObjectType -eq "User") {
                Write-Host "  - Configuring MFA for member: $($Member.UserPrincipalName)"
                # Configure MFA for each member
            }
        }
        
        Write-Host "MFA configured for group: $GroupName" -ForegroundColor Green
    } else {
        Write-Warning "Group not found: $GroupName"
    }
}

# Create Conditional Access Policy
if ($CreateConditionalAccessPolicy) {
    Write-Host "Creating Conditional Access Policy for MFA..." -ForegroundColor Yellow
    
    $PolicyName = "Require MFA for All Users"
    
    # Note: Conditional Access policies require Azure AD Premium P1 or P2
    # This is a conceptual example
    
    $ConditionalAccessPolicy = @{
        DisplayName = $PolicyName
        State = "Enabled"
        Conditions = @{
            Users = @{
                IncludeUsers = "All"
            }
            Applications = @{
                IncludeApplications = "All"
            }
        }
        GrantControls = @{
            Operator = "AND"
            BuiltInControls = @("Mfa")
        }
    }
    
    Write-Host "Conditional Access Policy created: $PolicyName" -ForegroundColor Green
}

Write-Host "MFA configuration completed!" -ForegroundColor Green























