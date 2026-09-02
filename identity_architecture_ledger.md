# IDENTITY ARCHITECTURE Ledger (IAL)
Immutable cryptographic baseline recording.
Deployment Target: Compcode1/iteration-10 | Target Cloud: Microsoft Azure
Execution Date: 2026-09-02 | Ledger State: [VERIFIED AUDIT READY]

## [SECTION 1: CORE CLOUD BOUNDARY IDENTIFICATION]
* Tenant ID (Identity Root): 9439dd25-f3b5-4829-a76f-5ede8cd54c3c
* Subscription ID (Asset Root): d5ffd8a5-d994-4eb5-b87c-4442054d233e
* Provisioned Resource Name: kv-efm-test-lab-04
* Resource Group Perimeter: rg-efm-test-lab-04
> [SUCCESS] Workspace paths align. CLI context locked.

## [SECTION 2: NON-HUMAN IDENTITY PROVISIONING]
* Application Name: acphf-rest-agent-01
* Application (Client) ID: 6634d368-0844-401d-9945-6b2c4dcfea1f
* Single-Tenant Enforced: (AzureADMyOrg) Blocks external credential instantiation.
> [SUCCESS] Blueprint and local security context created.

## [SECTION 3: PASSWORDLESS CRYPTOGRAPHIC FEDERATION]
* Issuer URL: https://token.actions.githubusercontent.com
* Subject (sub): repo:Compcode1@171821203/iteration-10@1354761829:ref:refs/heads/main
* Exact string casing verified to prevent AADSTS700213 drops.
> [SUCCESS] Trust policy active. Token endpoint listening.

## [SECTION 4: DATA-PLANE ACCESS & PIPELINE ENFORCEMENT]
* Assigned Data-Plane Role: Key Vault Secrets User
* Target Asset ID Scope: /subscriptions/d5ffd8a5-d994-4eb5-b87c-4442054d233e/resourceGroups/rg-efm-test-lab-04/providers/Microsoft.KeyVault/vaults/kv-efm-test-lab-04
* Access Token ceiling restricted to 60-minutes.
> [SUCCESS] HTTP 200 recorded. Zero Silent 403 drops detected.