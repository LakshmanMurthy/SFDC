// trigger SumCountOfContacts on Contact (before insert, after insert) {

//     Set<Id> accountIdSet = new Set<Id>();
//     Map<Id,Account> accMap = new Map<Id,Account>();
//     if(Trigger.isInsert){
//         for(Contact con : Trigger.new){
//             if(con.accountId != null){
//                 accountIdSet.add(con.accountId);
//             }
//         }

//     }

//     if(accountIdSet.size()>0){
//             for(Id Id : accountIdSet){
//                 accMap.put(Id, new Account(Id=Id, Sum_of_contacts_amount__c=0,Total_Contacts__c=0));
//             }
//     }

//     for(AggregateResult acc : [SELECT COUNT(Id) conCount, AccountId from Contact where accountId IN : accountIdSet group by accountId]){
//         // accMap.get(acc.accountId).Sum_of_contacts_amount__c += acc.Amount__c;
//         accMap.get(acc.AccountId).Total_Contacts__c += acc.conCount;
//     }

//     database.update(accMap.values());


// }

trigger SumCountOfContacts on Contact (after insert, after delete, after undelete) {
    Set<Id> accountIds = new Set<Id>();
    
    // Collecting affected account Ids
    if (Trigger.isInsert || Trigger.isUndelete) {
        for (Contact con : Trigger.new) {
            accountIds.add(con.AccountId);
        }
    }
    if (Trigger.isDelete) {
        for (Contact con : Trigger.old) {
            accountIds.add(con.AccountId);
        }
    }

    // Fetching existing Account records
    Map<Id, Account> existingAccounts = new Map<Id, Account>([SELECT Id, Total_Contacts__c, Sum_of_contacts_amount__c FROM Account WHERE Id IN :accountIds]);

    // Updating Account records
    List<Account> accountsToUpdate = new List<Account>();
    for (AggregateResult aggregate : [SELECT AccountId, COUNT(Id) conCount, SUM(Amount__c) totalAmount
                                      FROM Contact
                                      WHERE AccountId IN :accountIds
                                      GROUP BY AccountId]) {
        Id accountId = (Id)aggregate.get('AccountId');
        Integer contactCount = (Integer)aggregate.get('conCount');
        Decimal totalAmount = (Decimal)aggregate.get('totalAmount');

        // Fetching existing Account record or initializing a new one
        Account acc = existingAccounts.get(accountId);
        if (acc == null) {
            acc = new Account(Id = accountId);
        }

        // Updating contact count and total amount
        acc.Total_Contacts__c = contactCount;
        acc.Sum_of_contacts_amount__c = totalAmount;
        
        accountsToUpdate.add(acc);
    }

    // Update Account records
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
