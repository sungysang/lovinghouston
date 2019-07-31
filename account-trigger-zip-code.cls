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
