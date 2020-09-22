# Azure Cost Analysis Script
# Analyzes and reports on Azure spending

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$false)]
    [datetime]$StartDate = (Get-Date).AddDays(-30),
    
    [Parameter(Mandatory=$false)]
    [datetime]$EndDate = Get-Date,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "cost-analysis-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
)

# Connect to Azure
Connect-AzAccount -ErrorAction Stop

Write-Host "Analyzing Azure costs..." -ForegroundColor Green
Write-Host "Start Date: $StartDate" -ForegroundColor Cyan
Write-Host "End Date: $EndDate" -ForegroundColor Cyan

# Get subscription context
$Subscription = Get-AzContext
Write-Host "Subscription: $($Subscription.Subscription.Name)" -ForegroundColor Cyan

# Get cost data using Consumption API
$CostData = @()

try {
    # Query cost data
    $Query = @{
        type = "ActualCost"
        timeframe = "Custom"
        timePeriod = @{
            from = $StartDate.ToString("yyyy-MM-dd")
            to = $EndDate.ToString("yyyy-MM-dd")
        }
        dataset = @{
            granularity = "Daily"
            aggregation = @{
                totalCost = @{
                    name = "PreTaxCost"
                    function = "Sum"
                }
            }
            grouping = @(
                @{
                    type = "Dimension"
                    name = "ResourceGroup"
                }
            )
        }
    }
    
    # Get cost management data
    $Scope = "/subscriptions/$($Subscription.Subscription.Id)"
    
    Write-Host "Retrieving cost data..." -ForegroundColor Yellow
    
    # Use Azure Cost Management API
    $CostResults = Get-AzConsumptionUsageDetail `
        -StartDate $StartDate `
        -EndDate $EndDate `
        -ErrorAction SilentlyContinue
    
    if ($CostResults) {
        $CostResults | ForEach-Object {
            $CostData += [PSCustomObject]@{
                Date = $_.Date
                ResourceGroup = $_.ResourceGroup
                ResourceName = $_.ResourceName
                MeterCategory = $_.MeterCategory
                MeterName = $_.MeterName
                Cost = $_.PreTaxCost
                Currency = $_.Currency
            }
        }
    }
    
    # Filter by resource group if specified
    if ($ResourceGroupName) {
        $CostData = $CostData | Where-Object { $_.ResourceGroup -eq $ResourceGroupName }
    }
    
    # Summary statistics
    $TotalCost = ($CostData | Measure-Object -Property Cost -Sum).Sum
    $CostByResourceGroup = $CostData | 
        Group-Object ResourceGroup | 
        Select-Object @{Name="ResourceGroup"; Expression={$_.Name}}, 
                     @{Name="TotalCost"; Expression={($_.Group | Measure-Object -Property Cost -Sum).Sum}},
                     @{Name="RecordCount"; Expression={$_.Count}}
    
    Write-Host "`nCost Analysis Summary" -ForegroundColor Green
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "Total Cost: $TotalCost $($CostData[0].Currency)" -ForegroundColor Yellow
    Write-Host "`nCost by Resource Group:" -ForegroundColor Cyan
    $CostByResourceGroup | Format-Table -AutoSize
    
    # Export to CSV
    $CostData | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "`nCost data exported to: $OutputPath" -ForegroundColor Green
    
} catch {
    Write-Warning "Cost Management API may not be available. Using alternative method..."
    
    # Alternative: Get resource costs by querying resource tags
    Write-Host "Querying resources for cost estimation..." -ForegroundColor Yellow
    
    $Resources = Get-AzResource -ErrorAction SilentlyContinue
    
    if ($ResourceGroupName) {
        $Resources = $Resources | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }
    }
    
    $ResourceSummary = $Resources | 
        Group-Object ResourceType | 
        Select-Object @{Name="ResourceType"; Expression={$_.Name}}, 
                     @{Name="Count"; Expression={$_.Count}}
    
    Write-Host "`nResource Summary:" -ForegroundColor Cyan
    $ResourceSummary | Format-Table -AutoSize
    
    Write-Host "`nNote: For detailed cost analysis, ensure Cost Management API is enabled." -ForegroundColor Yellow
}

Write-Host "Cost analysis completed!" -ForegroundColor Green


























