# Execution Variables
$tenantId = "9439dd25-f3b5-4829-a76f-5ede8cd54c3c"
$subId = "d5ffd8a5-d994-4eb5-b87c-4442054d233e"
$rgName = "rg-efm-test-lab-04"
$kvName = "kv-efm-test-lab-04"
$appName = "acphf-rest-agent-01"
$lawName = "law-efm-audit"
$diagSettingName = "diag-kv-audit-tkav"
$repoSubject = "repo:Compcode1@$githubUserId/iteration-10@$githubRepoId:ref:refs/heads/main"

$graphHeaders = @{ Authorization = "Bearer $graphToken"; "Content-Type" = "application/json" }
$armHeaders = @{ Authorization = "Bearer $armToken"; "Content-Type" = "application/json" }

# 1. Create App Registration
$appBody = @{
    displayName = $appName
    uniqueName = $appName
    signInAudience = "AzureADMyOrg"
} | ConvertTo-Json
$app = Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/applications" -Headers $graphHeaders -Body $appBody
$appId = $app.appId
$appObjectId = $app.id
Write-Host "::add-mask::$appId"
Write-Host "App Registration Created"

# 2. Create Service Principal
$spBody = @{ appId = $appId } | ConvertTo-Json
$sp = Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/servicePrincipals" -Headers $graphHeaders -Body $spBody
$spObjectId = $sp.id
Write-Host "Service Principal Created"

# 3. Create Federated Identity Credential
$ficBody = @{
    name = "$appName/github-actions-federation"
    issuer = "https://token.actions.githubusercontent.com"
    subject = $repoSubject
    description = "GitHub Actions Federation"
    audiences = @("api://AzureADTokenExchange")
} | ConvertTo-Json -Depth 3
Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/applications/$appObjectId/federatedIdentityCredentials" -Headers $graphHeaders -Body $ficBody
Write-Host "Federated Identity Credential Established"

# 4. Create Role Assignment (Key Vault Secrets User: 4633458b-17de-408a-b874-0445c86b69e6)
$roleDefId = "/subscriptions/$subId/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6"
$scope = "/subscriptions/$subId/resourceGroups/$rgName/providers/Microsoft.KeyVault/vaults/$kvName"
$roleAssignmentId = [guid]::NewGuid().ToString()
$roleBody = @{
    properties = @{
        roleDefinitionId = $roleDefId
        principalId = $spObjectId
        principalType = "ServicePrincipal"
    }
} | ConvertTo-Json -Depth 3
Invoke-RestMethod -Method Put -Uri "https://management.azure.com$scope/providers/Microsoft.Authorization/roleAssignments/$($roleAssignmentId)?api-version=2022-04-01" -Headers $armHeaders -Body $roleBody
Write-Host "Data-Plane Role Assignment Complete"

# 5. Create Log Analytics Workspace
$lawBody = @{
    location = (az group show --name $rgName --query location -o tsv)
    properties = @{
        sku = @{ name = "PerGB2018" }
        retentionInDays = 30
    }
} | ConvertTo-Json -Depth 3
$law = Invoke-RestMethod -Method Put -Uri "https://management.azure.com/subscriptions/$subId/resourcegroups/$rgName/providers/Microsoft.OperationalInsights/workspaces/$($lawName)?api-version=2022-10-01" -Headers $armHeaders -Body $lawBody
Write-Host "Log Analytics Workspace Provisioned"

# 6. Create Diagnostic Setting
$diagBody = @{
    properties = @{
        workspaceId = $law.id
        logs = @(@{ category = "AuditEvent"; enabled = $true })
        metrics = @(@{ category = "AllMetrics"; enabled = $true })
    }
} | ConvertTo-Json -Depth 3
Invoke-RestMethod -Method Put -Uri "https://management.azure.com$scope/providers/microsoft.insights/diagnosticSettings/$($diagSettingName)?api-version=2021-05-01-preview" -Headers $armHeaders -Body $diagBody
Write-Host "Diagnostic Trap Configured"