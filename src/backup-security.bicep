// Backup security (Resource Guard / multi-user authorisation) delegation to HybrIT Services NZ.
// Deploy ONLY to the dedicated subscription that holds the Resource Guard, never alongside
// full.bicep or reader.bicep on the same subscription.
// No offboarding role is granted here on purpose: only the client can remove this delegation.
targetScope = 'subscription'

import { managedByTenantId, mspOfferName, groups, roles } from 'shared/nz-tenant.bicep'

module lighthouse 'shared/lighthouse.bicep' = {
  name: 'hybrit-nz-lighthouse-backup-security'
  params: {
    mspOfferName: mspOfferName
    mspOfferDescription: 'HybrIT Services NZ backup security services'
    managedByTenantId: managedByTenantId
    authorizations: [
      {
        principalId: groups.readers.id
        principalIdDisplayName: groups.readers.name
        roleDefinitionId: roles.reader
      }
      {
        principalId: groups.backupSecurity.id
        principalIdDisplayName: groups.backupSecurity.name
        roleDefinitionId: roles.contributor
      }
    ]
  }
}

output mspOffer string = lighthouse.outputs.mspOffer
output authorizations array = lighthouse.outputs.authorizations
