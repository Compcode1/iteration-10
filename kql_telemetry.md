# KQL TELEMETRY AUDIT ARTIFACT
**Target Vault:** kv-efm-test-lab-04
**Execution Context:** Asynchronous Audit Validation

Execute the following Kusto Query Language (KQL) payload in your Log Analytics Workspace to mathematically prove data-plane access and validate the OIDC trust matrix.

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where Resource == "kv-efm-test-lab-04"
| extend SafeCallerIpAddress = column_ifexists("CallerIpAddress", "Pending Schema Sync")
| extend SafeIdentityClaim = column_ifexists("identity_claim_sub_s", "Pending Schema Sync")
| project TimeGenerated, VaultName = Resource, OperationName, ResultSignature, SafeCallerIpAddress, SafeIdentityClaim
| sort by TimeGenerated desc