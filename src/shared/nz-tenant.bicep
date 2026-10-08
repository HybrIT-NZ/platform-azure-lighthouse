// Single source of truth for the HybrIT Services NZ managing tenant, its Lighthouse
// groups and the built-in Azure roles they are granted. Imported at compile time by
// every template in src/, so each compiled JSON in templates/ stays self-contained.

@export()
@description('HybrIT Services NZ Entra ID tenant (hybrit.nz)')
var managedByTenantId = '77b037f9-03df-453a-aaf2-df88dd20320a'

@export()
@description('Offer name shown to the client under Service providers. Also seeds the registration GUIDs, so keep it stable.')
var mspOfferName = 'HybrIT Services NZ'

// Security groups in the NZ tenant. Every group except Readers is PIM-eligible only
// (no standing members): activation requires MFA, no approver, 8 hours maximum.
// Readers holds standing membership.
@export()
var groups = {
  privilegeContributors: {
    id: '31c79af5-c7e0-415c-929a-6db016238c5d'
    name: 'Lighthouse - Azure Privilege Contributors'
  }
  contributors: {
    id: '20831dff-171f-417c-8b7b-c611aa75ba2d'
    name: 'Lighthouse - Azure Contributors'
  }
  operators: {
    id: 'b823e65c-1820-436f-bb5d-6775cec42bba'
    name: 'Lighthouse - Azure Operators'
  }
  readers: {
    id: '0565ba94-48cb-4552-b96b-7f061f07f3fe'
    name: 'Lighthouse - Azure Readers'
  }
  backupSecurity: {
    id: '3c7f5515-c39a-4a6d-96e0-d5a16f447cb8'
    name: 'Lighthouse - Azure Backup Security'
  }
}

// Built-in role definition IDs: https://learn.microsoft.com/azure/role-based-access-control/built-in-roles
// Lighthouse rejects roles that carry DataActions. Log Analytics Contributor gained one
// (workspaces/jobs/export/action), so it is deliberately absent; Monitoring Contributor
// and Contributor cover the same operational need.
@export()
var roles = {
  contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  userAccessAdministrator: '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  managedServicesRegistrationAssignmentDelete: '91c1777a-f3dc-4fae-b103-61d183457e46'
  resourcePolicyContributor: '36243c78-bf99-498c-9df9-86d9f8d28608'
  monitoringContributor: '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
  virtualMachineContributor: '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
  backupOperator: '00c29273-979b-4161-815c-10b084fb9324'
  automationOperator: 'd3881f73-407a-4167-8283-e981cbba0404'
  automationRunbookOperator: '5fb5aef8-1081-4b8e-bb16-9d5d0385bab5'
  managedApplicationOperator: 'c7393b34-138c-406f-901b-d8cf2b17e6ae'
  siteRecoveryOperator: '494ae006-db33-4328-bf46-533a6560a3ca'
  desktopVirtualizationUserSessionOperator: 'ea4bfff8-7fb4-485a-aadd-d4129a0ffaa6'
}
