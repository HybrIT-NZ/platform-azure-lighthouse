// Full managed service delegation to HybrIT Services NZ.
targetScope = 'subscription'

import { managedByTenantId, mspOfferName, groups, roles } from 'shared/nz-tenant.bicep'

var operatorRoles = [
  roles.reader
  roles.virtualMachineContributor
  roles.backupOperator
  roles.monitoringContributor
  roles.automationOperator
  roles.automationRunbookOperator
  roles.managedApplicationOperator
  roles.siteRecoveryOperator
  roles.desktopVirtualizationUserSessionOperator
]

var authorizations = concat(
  [
    {
      principalId: groups.privilegeContributors.id
      principalIdDisplayName: groups.privilegeContributors.name
      roleDefinitionId: roles.contributor
    }
    {
      // Lets HybrIT remove its own delegation when offboarding
      principalId: groups.privilegeContributors.id
      principalIdDisplayName: groups.privilegeContributors.name
      roleDefinitionId: roles.managedServicesRegistrationAssignmentDelete
    }
    {
      principalId: groups.privilegeContributors.id
      principalIdDisplayName: groups.privilegeContributors.name
      roleDefinitionId: roles.resourcePolicyContributor
    }
    {
      // User Access Administrator, restricted to granting Contributor to managed
      // identities (needed for DeployIfNotExists/Modify policy remediation)
      principalId: groups.privilegeContributors.id
      principalIdDisplayName: groups.privilegeContributors.name
      roleDefinitionId: roles.userAccessAdministrator
      delegatedRoleDefinitionIds: [
        roles.contributor
      ]
    }
    {
      principalId: groups.contributors.id
      principalIdDisplayName: groups.contributors.name
      roleDefinitionId: roles.contributor
    }
    {
      principalId: groups.readers.id
      principalIdDisplayName: groups.readers.name
      roleDefinitionId: roles.reader
    }
  ],
  map(operatorRoles, role => {
    principalId: groups.operators.id
    principalIdDisplayName: groups.operators.name
    roleDefinitionId: role
  })
)

module lighthouse 'shared/lighthouse.bicep' = {
  name: 'hybrit-nz-lighthouse-full'
  params: {
    mspOfferName: mspOfferName
    mspOfferDescription: 'HybrIT Services NZ managed services'
    managedByTenantId: managedByTenantId
    authorizations: authorizations
  }
}

output mspOffer string = lighthouse.outputs.mspOffer
output authorizations array = lighthouse.outputs.authorizations
