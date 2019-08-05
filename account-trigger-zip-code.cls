trigger populateSchoolDistrictBasedOnZip on Account (before update, before insert) {

    for (Account a : Trigger.new) {

        String schoolZip = a.BillingPostalCode;
        String schoolType = a.Type;
            if (a.parentid != null || schoolType != 'School' || schoolZip == null) {
                  return;
            }
        		else {
                    List<Account> matchedSchooldistricts = [Select Id from Account where Type = 'School District' and BillingPostalCode != null and BillingPostalCode = :schoolZip];
                        if (matchedSchooldistricts.size() > 1 || matchedSchooldistricts.isEmpty()) {
                            return;    
                        }
                        else {
                            a.parentId = matchedSchooldistricts[0].id;
                        }
                      }
    }
}

     /* 

Trigger should be after update/insert

1. Loop through to add zip codes to a set. Filtering by using Record Type = church, zip is filled
    and parent account is blank. Declared the Set outside of for loop due to scope.

2. Run a soql to find all matched Parent Accounts with same zip codes 

3. Create a map of Account with zip code as key

4. Populate the Account lookup with the key value.

    Set<String> zipCodeSet = new Set<String>();

    for (Account a : [SELECT BillingPostalCode
                        FROM Account
                        WHERE RecordTypeId = '0121N000000qpORQAY'
                        AND Id IN :Trigger.new
                        AND ParentId = null //ParentId or DistrictLookupId?
                        AND BillingPostalCode != null]) {

                            zipCodeSet.add(a.BillingPostalCode);
                        }
    
    List<Account> matchedSchoolDistricts = new List<Account>([SELECT Id, BillingPostalCode
                                            FROM Account
                                            WHERE Type = 'School District' 
                                            AND BillingPostalCode IN :zipCodeSet]);

    Map<String, Account> zipCodeMap = new Map<String, Account> ();
    Set<String> zipCodeKeyDuplicates = new Set<String>();
    for (Account p : matchedSchoolDistricts) {

        if (zipCodeMap.containsKey(p.BillingPostalCode)) {
            zipCodeKeyDuplicates.add(p.BillingPostalCode);
        }
        else {
            zipCodeMap.put(p.BillingPostalCode, p);
        }
    }

    for (String zipCode : zipCodeKeyDuplicates) {
        zipCodeMap.remove(zipCode);
    }
        // if the zip code has already been added to the map, that means there's multiple School District
        // accounts with the same zipcode. Therefore, if the map containskey (billingpostalcode), this key
        // should be removed from the map. Biggest issue is this solution will only work if there's an even 
        // number of duplicate zip codes

        // possible solution: create a list of keys that I can add to if contains key. After the first loop,
        // loop through this keylist and use it to remove all keys from the map.
        // if contains key ==> add to keylist ==> for string key : keylist {map.remove(key)}
        // COMPLETED
        
    for (account a : Trigger.New) {
        if (zipCodeMap.containsKey(a.BillingPostalCode)) {
            Account match = zipCodeMap.get(a.BillingPostalCode);
            a.ParentId = match.Id;
        }
    } 

  */
