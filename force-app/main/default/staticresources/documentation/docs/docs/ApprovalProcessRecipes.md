---
layout: default
---
# ApprovalProcessRecipes class

Demonstrate how to start an approval process And how to approve a record that&apos;s entered an approval process.

---
## Methods
### `approveNextRecordStep(Approval.ProcessResult workItems)` → `Approval.ProcessResult`
### `startApprovalProcess(Id recordId,String approvalProcessName,Id userId)` → `Approval.ProcessResult`
### `startApprovalProcess(Id recordId,String approvalProcessName)` → `Approval.ProcessResult`

Starts a given approval process for the specified record, assuming the submitting user is the apex execution context user.

#### Parameters

| Param | Description |
| ----- | ----------- |
|`recordId` |   the record to approve |
|`approvalProcessName` |  the approval process to use |

---
