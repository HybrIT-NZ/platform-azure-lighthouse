![HybrIT logo](img/HybrITLogo.png)

# HybrIT Services NZ - Azure Lighthouse

These templates let HybrIT Services NZ clients delegate access to some or all of their Azure subscriptions to HybrIT Services NZ through [Azure Lighthouse](https://learn.microsoft.com/azure/lighthouse/overview).

Access is granted to security groups in the HybrIT Services NZ Entra ID tenant (`hybrit.nz`), never to individual accounts. HybrIT NZ engineers sign in with their own HybrIT NZ account, subject to HybrIT's MFA and Conditional Access policies, and every action they take in your subscription is recorded in your Azure Activity Log under their name. You keep full control: you can see and remove the delegation at any time.

No HybrIT NZ engineer holds standing write access to your subscription. Every group except Readers uses [Privileged Identity Management for Groups](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/concept-pim-for-groups) in the HybrIT NZ tenant: engineers are eligible, not members, and must activate the group with MFA for a maximum of 8 hours before any write role applies. The PIM licences sit in HybrIT's tenant, at no cost to you. See Microsoft's [announcement](https://azure.microsoft.com/blog/privileged-identity-management-with-azure-lighthouse-enables-zero-trust/) for how PIM and Azure Lighthouse work together.

- [Choose a template](#choose-a-template)
- [Enrol a single subscription](#enrol-a-single-subscription)
- [Enrol all subscriptions](#enrol-all-subscriptions)
- [What access is granted](#what-access-is-granted)
- [Moving from the HybrIT UK/Global delegation](#moving-from-the-hybrit-ukglobal-delegation)
- [Remove access](#remove-access)
- [Maintaining these templates](#maintaining-these-templates)

## Choose a template

| Template | Use it for |
| --- | --- |
| [`templates/full.json`](templates/full.json) | Managed service clients. Full operational access. |
| [`templates/reader.json`](templates/reader.json) | Discovery and review engagements. Read only. Deploying `full.json` later upgrades it in place. |
| [`templates/backup-security.json`](templates/backup-security.json) | A **dedicated** subscription that holds an Azure Backup [Resource Guard](https://learn.microsoft.com/azure/backup/multi-user-authorization). Never deploy another template to that subscription. |

## Enrol a single subscription

Sign in with an account that holds **Owner** on the subscription, select it, and deploy. Azure PowerShell:

```powershell
Connect-AzAccount
Set-AzContext -Subscription '<subscription-id>'
New-AzSubscriptionDeployment -Location australiaeast `
  -TemplateUri 'https://raw.githubusercontent.com/HybrIT-NZ/platform-azure-lighthouse/main/templates/full.json'
```

Azure CLI:

```bash
az login
az deployment sub create --subscription '<subscription-id>' --location australiaeast \
  --template-uri 'https://raw.githubusercontent.com/HybrIT-NZ/platform-azure-lighthouse/main/templates/full.json'
```

Swap `full.json` for `reader.json` or `backup-security.json` as needed.

## Enrol all subscriptions

Exclude any Resource Guard subscription by name first.

```powershell
$subs = Get-AzSubscription | Where-Object { $_.State -eq 'Enabled' -and $_.Name -notlike '*BackupSecurity*' }
foreach ($sub in $subs) {
    Set-AzContext -Subscription $sub.Id | Out-Null
    New-AzSubscriptionDeployment -Location australiaeast `
      -TemplateUri 'https://raw.githubusercontent.com/HybrIT-NZ/platform-azure-lighthouse/main/templates/full.json'
}
```

## What access is granted

All roles are Azure built-in roles ([reference](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles)). Azure Lighthouse does not allow Owner, custom roles or roles that read data directly.

| HybrIT NZ group | Role | Template |
| --- | --- | --- |
| Lighthouse - Azure Privilege Contributors | Contributor | full |
| Lighthouse - Azure Privilege Contributors | Resource Policy Contributor | full |
| Lighthouse - Azure Privilege Contributors | User Access Administrator, limited to granting Contributor to managed identities for policy remediation | full |
| Lighthouse - Azure Privilege Contributors | Managed Services Registration assignment Delete Role (lets HybrIT remove its own access) | full |
| Lighthouse - Azure Contributors | Contributor | full |
| Lighthouse - Azure Operators | Reader, Virtual Machine Contributor, Backup Operator, Monitoring Contributor, Automation Operator, Automation Runbook Operator, Managed Application Operator, Site Recovery Operator, Desktop Virtualization User Session Operator | full |
| Lighthouse - Azure Readers | Reader | all |
| Lighthouse - Azure Backup Security | Contributor | backup-security |

The backup security template deliberately omits the delete role, so only you can remove that delegation.

## Moving from the HybrIT UK/Global delegation

These templates register a separate offer (**HybrIT Services NZ**) and sit alongside any existing HybrIT UK/Global delegation instead of replacing it. To move across:

1. Deploy the NZ template to each subscription.
2. HybrIT NZ confirms its engineers can see and work in the subscription.
3. Remove the old **HybrIT IT Services** delegation and offer as described in [Remove access](#remove-access), leaving **HybrIT Services NZ** in place.

## Remove access

In the Azure portal search for **Service providers**. Under **Delegations**, select the HybrIT delegation and choose **Delete**. Then under **Service provider offers**, delete the matching offer.

![Delegations](img/serviceproviders.png)

![Service provider offers](img/serviceprovideroffers.png)

## Maintaining these templates

Source is Bicep in [`src/`](src). Tenant, group and role IDs live only in [`src/shared/nz-tenant.bicep`](src/shared/nz-tenant.bicep). After any change, rebuild the deployable JSON and commit both:

```bash
for t in full reader backup-security; do az bicep build --file src/$t.bicep --outfile templates/$t.json; done
```

Changing an authorisation only affects a client once the template is redeployed to their subscription. Before adding a role, check it has no `DataActions` (`az role definition list --name <id> --query "[0].permissions[0].dataActions"`): Lighthouse rejects those for new delegations.
