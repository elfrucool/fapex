@IsTest
public class FunctionsTestUtil {
    // sample SObjects to test some functions
    // you might modify this method to make insertions succeed
    public static void insertAccountWithTwoContacts() {
        Account account = new Account(Name = 'a1');
        insert account;

        List<Contact> contacts = new List<Contact>{
                new Contact(LastName = 'l1', FirstName = 'f1', AccountId = account.Id),
                new Contact(LastName = 'Ross', FirstName = 'Bob', AccountId = account.Id)
        };

        insert contacts;
    }
}