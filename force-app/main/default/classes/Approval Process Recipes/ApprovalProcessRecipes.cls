/**
 * @description Demonstrate how to start an approval process
 *   And how to approve a record that's entered an approval process.
 * @group Approval Process Recipes
 */
public with sharing class ApprovalProcessRecipes {
    public Approval.ProcessResult startApprovalProcess(
        Id recordId,
        String approvalProcessName,
        Id userId
    ) {
        Approval.ProcessSubmitRequest processSubmitRequest = new Approval.ProcessSubmitRequest();
        processSubmitRequest.setObjectId(recordId);
        processSubmitRequest.setComments('Submitted for approval by apex code');
        processSubmitRequest.setProcessDefinitionNameOrId(approvalProcessName);
        processSubmitRequest.setSubmitterId(userId);
        processSubmitRequest.setSkipEntryCriteria(true);

        Approval.ProcessResult result = Approval.process(processSubmitRequest);
        return result.getNewWorkItemIds();
    }

    /**
     * @description               Starts a given approval process for
     * the specified record, assuming the submitting user is the apex
     * execution context user.
     * @param recordId  the record to approve
     * @param approvalProcessName the approval process to use
     */
    public Approval.ProcessResult startApprovalProcess(
        Id recordId,
        String approvalProcessName
    ) {
        Id userId = UserInfo.getUserId();

        return startApprovalProcess(recordId, approvalProcessName, userId);
    }

    public Approval.ProcessResult approveNextRecordStep(
        Approval.ProcessResult workItems
    ) {
        Id activeWorkItemId = workItems.getNewWorkItemIds()[0];
        Approval.ProcessWorkItemRequest approveStep = new Approval.ProcessWorkItemRequest();
        approveStep.setComments('Approving this step via APEX code');
        approveStep.setAction('Approve');
        approveStep.setWorkItemId(activeWorkItemId);
        return Approval.process(approveStep);
    }
}
