@IsTest
public class FunctionsTest {
    @IsTest
    static void testConstant() {
        System.assertEquals('foo', Functions.constant('foo').apply(123));
    }

    @IsTest
    static void testIdentity() {
        System.assertEquals(123, Functions.identity().apply(123));
    }

    @IsTest
    static void testToString() {
        System.assertEquals('123', Functions.toString().apply(123));
    }

    @IsTest
    static void testConcatenateString() {
        System.assertEquals('foobar', Functions.concatenateString().apply('foo', 'bar'));
    }

    @IsTest
    static void testIsEqualToPredicate() {
        System.assertEquals(true, Functions.isEqualToPredicate(2).apply(2));
        System.assertEquals(false, Functions.isEqualToPredicate('foo').apply('bar'));
    }

    @IsTest
    static void testGetSObjectField() {
        Lead lead = new Lead(FirstName = 'fname', LastName = 'lname', Company = 'the company');

        System.assertEquals('fname', Functions.getSObjectField('FirstName').apply(lead));
    }

    @IsTest
    static void testGetSObjectChildren() {
        FunctionsTestUtil.insertAccountWithTwoContacts();

        Account account = [SELECT Id, (SELECT Id, FirstName, LastName, AccountId FROM Contacts) FROM Account];

        List<Contact> contacts = [SELECT Id, FirstName, LastName, AccountId FROM Contact];

        System.assertEquals(
                contacts,
                Functions.getSObjectChildren('Contacts').apply(account)
        );
    }

    @IsTest
    static void testApplyArgToFunction() {
        System.assertEquals(
                '123',
                Functions.applyArgToFunction()
                        .apply(123)
                        .apply(Functions.toString())
        );
    }

    @IsTest
    static void appendToList() {
        System.assertEquals(
                new List<Object> {1, 2, 3},
                Functions.appendToList()
                        .apply(new List<Object> {1, 2})
                        .apply(3)
        );
    }

    @IsTest
    static void split() {
        System.assertEquals(
                new List<String>{'foo', 'bar', 'baz'},
                Functions.split('\\|').apply('foo|bar|baz')
        );
        System.assertEquals(
                new List<String>{'foo', 'bar', 'baz'},
                Functions.split().apply('foo,bar,baz')
        );
    }

    @IsTest
    static void negate() {
        System.assertEquals(false, Functions.negate().apply(true));
        System.assertEquals(true, Functions.negate().apply(false));
    }
}
