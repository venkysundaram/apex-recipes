@isTest
public with sharing class ApprovalProcessRecipes_Tests {
    static String approvalProcessName = [
        SELECT name
        FROM processdefinition
        LIMIT 1
    ][0]
    .Name;

    @IsTest
    static void testSubmitAccountToApprovalProcessPositive() {
        Account acct = (Account) TestFactory.createSObject(
            new Account(name = 'TestAccount', Industry = 'Not Manufacturing'),
            true
        );

        ApprovalProcessRecipes apr = new ApprovalProcessRecipes();
        Approval.ProcessResult result = apr.startApprovalProcess(
            acct.id,
            approvalProcessName
        );

        System.assert(result.isSuccess(), 'expected to receive true');
    }

    @IsTest
    static void testSubmitAccountToApprovalProcessPositiveSetUserId() {
        User notAdmin = TestFactory.createTestUser(true, 'Standard User');

        ApprovalProcessRecipes apr = new ApprovalProcessRecipes();
        Approval.ProcessResult result;
        System.runAs(notAdmin) {
            Account acct = (Account) TestFactory.createSObject(
                new Account(
                    name = 'TestAccount',
                    Industry = 'Not Manufacturing'
                ),
                true
            );
            test.startTest();
            result = apr.startApprovalProcess(acct.id, approvalProcessName);
            test.stopTest();
        }

        System.assert(
            result.isSuccess(),
            'expected to receive new work item ids'
        );
        ProcessInstanceStep step = [
            SELECT FIELDS(standard)
            FROM ProcessInstanceStep
            WHERE
                StepStatus = 'started'
                AND Comments = 'Submitted for approval by apex code'
            LIMIT 1
        ];
        // system.assertNotEquals(
        //     step.ActorId,
        //     step.OriginalActorId,
        //     'expected to see that the actor is not the non-admin user'
        // );
    }
}
