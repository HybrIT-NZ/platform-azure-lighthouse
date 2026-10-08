// Read-only delegation to HybrIT Services NZ (discovery and review engagements).
// Deploying full.bicep later to the same subscription upgrades this in place.
targetScope = 'subscription'

import { managedByTenantId, mspOfferName, groups, roles } from 'shared/nz-tenant.bicep'

module lighthouse 'shared/lighthouse.bicep' = {
  name: 'hybrit-nz-lighthouse-reader'
  params: {
    mspOfferName: mspOfferName
    mspOfferDescription: 'HybrIT Services NZ review services (read only)'
    managedByTenantId: managedByTenantId
    authorizations: [
      {
        principalId: groups.readers.id
        principalIdDisplayName: groups.readers.name
        roleDefinitionId: roles.reader
      }
    ]
  }
}

output mspOffer string = lighthouse.outputs.mspOffer
output authorizations array = lighthouse.outputs.authorizations
