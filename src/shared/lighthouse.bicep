// Registers the HybrIT Services NZ offer on the target subscription and assigns it.
targetScope = 'subscription'

param mspOfferName string
param mspOfferDescription string
param managedByTenantId string
param authorizations array

// Seeded with the managing tenant so this offer can never collide with the HybrIT
// UK/Global offer on a subscription that already carries both. Deploying a different
// NZ template (e.g. Reader then Full) to the same subscription updates it in place.
var mspRegistrationName = guid(managedByTenantId, mspOfferName)

resource registrationDefinition 'Microsoft.ManagedServices/registrationDefinitions@2022-10-01' = {
  name: mspRegistrationName
  properties: {
    registrationDefinitionName: mspOfferName
    description: mspOfferDescription
    managedByTenantId: managedByTenantId
    authorizations: authorizations
  }
}

resource registrationAssignment 'Microsoft.ManagedServices/registrationAssignments@2022-10-01' = {
  name: mspRegistrationName
  properties: {
    registrationDefinitionId: registrationDefinition.id
  }
}

output mspOffer string = 'Managed by ${mspOfferName}'
output authorizations array = authorizations
