@IsTest
public class StreamTest {
    static Function1 times2 = new MultiplyByTwoFunction();
    static Function1 duplicateItem = new DuplicateItemFunction();
    static Function1 isOdd = new IsOddFunction();
    static Function2 add = new AddFunction();
    static Function2 concat = Functions.concatenateString();
    static Function1 toString = Functions.toString();

    static List<Integer> items = new List<Integer>{1, 2, 3, 4};

    @IsTest
    static void toList() {
        Stream stream = Stream.of(items);

        System.assertEquals(
                items,
                stream.toList()
        );
    }

    @IsTest
    static void ofValue() {
        System.assertEquals(
                Stream.of(new List<Object>{1}).toList(),
                Stream.ofValue(1).toList()
        );
    }

    @IsTest
    static void fmap() {
        Stream stream = Stream.of(items);

        System.assertEquals(
                new List<Integer>{4, 8, 12, 16},
                stream.fmap(times2)
                        .fmap(times2)
                        .toList()
        );
    }

    @IsTest
    static void bind1() {
        Stream stream = Stream.of(items);

        System.assertEquals(
                new List<Integer>{1, 1, 2, 2, 3, 3, 4, 4},
                stream.bind(duplicateItem)
                        .toList()
        );
    }

    @IsTest
    static void bind2() {
        Stream stream = Stream.of(items);

        System.assertEquals(
                new List<Integer>{1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4},
                stream.bind(duplicateItem)
                        .bind(duplicateItem)
                        .toList()
        );
    }

    @IsTest
    static void filter() {
        Stream stream = Stream.of(items);

        System.assertEquals(
                new List<Integer>{1, 3},
                stream.filter(isOdd)
                        .toList()
        );
    }

    @IsTest
    static void foldLeft1() {
        Stream stream = Stream.of(items);

        System.assertEquals(
                1 + 2 + 3 + 4,
                stream.foldLeft(add, 0)
        );

        System.assertEquals(
                '13',
                stream.filter(isOdd)
                        .fmap(toString)
                        .foldLeft(concat, '')
        );

        System.assertEquals(
                (1 + 2 + 3 + 4) * 4,
                stream.bind(duplicateItem)
                        .bind(duplicateItem)
                        .foldLeft(add, 0)
        );
    }

    @IsTest
    static void streamIsApplicative() {
        Applicative streamAsAp = Stream.ofValue(1);
        System.assertEquals(Stream.ofValue('1').toList(), ((Stream)streamAsAp.pure('1')).toList());

        System.assertEquals( // apply invocation over simple stream
                new List<Integer>{2, 4, 6, 7},
                Stream.of(new List<Function1>{times2, add.apply(5)})
                        .apply(Stream.of(new List<Integer>{1, 2}))
                        .toList()
        );

        System.assertEquals( // apply invocation over transformed stream
                new List<String>{'2', '4', '6', '7'},
                Stream.of(new List<Function1>{times2, add.apply(5)})
                        .fmap(Function1.andThenFn(Functions.toString()))
                        .apply(Stream.of(new List<Integer>{1, 2}))
                        .toList()
        );

        System.assertEquals( // liftA2 invocation over simple stream
                new List<Integer> {4, 5, 5, 6},
                Stream.of(new List<Integer> {1, 2})
                        .liftA2(add, Stream.of(new List<Integer> {3, 4}))
                        .toList()
        );

        System.assertEquals( // liftA2 invocation over transformed stream
                new List<Integer> {5, 6, 7, 8},
                Stream.of(new List<Integer> {1, 2})
                        .fmap(times2)
                        .liftA2(add, Stream.of(new List<Integer> {3, 4}))
                        .toList()
        );
    }

    @IsTest
    static void streamIsMonad() {
        Monad streamAsMonad = Stream.ofValue(1);
        System.assertEquals(
                new List<Integer> {1, 1},
                ((Stream)streamAsMonad.bind(duplicateItem)).toList()
        );
    }

    @IsTest
    static void moreComplexExample() {
        FunctionsTestUtil.insertAccountWithTwoContacts();

        Test.startTest();
        List<Account> accounts = [
                SELECT Id, (SELECT Id, FirstName, LastName, AccountId FROM Contacts)
                FROM Account
        ];

        List<Object> filteredContacts =
                (List<Object>) Stream.of(accounts)
                        .bind(Functions.getSObjectChildren('Contacts').andThen(Stream.ofFn()))
                        .filter(Functions.getSObjectField('LastName')
                                .andThen(Functions.isEqualToPredicate('Ross')))
                        .toList();

        Test.stopTest();

        System.assertEquals(1, filteredContacts.size());

        Contact filteredContact = (Contact)filteredContacts.get(0);
        System.assertEquals('Bob', filteredContact.FirstName);
    }

    // Int -> Int
    public class MultiplyByTwoFunction extends Function1 {
        public override Object apply(Object arg) {
            return ((Integer)arg) * 2;
        }
    }

    // x -> Stream x
    public class DuplicateItemFunction extends Function1 {
        public override Object apply(Object arg) {
            return Stream.of(new List<Object>{arg, arg});
        }
    }

    // x -> Boolean
    public class IsOddFunction extends Function1 {
        public override Object apply(Object arg) {
            Integer value = (Integer)arg;
            return Math.mod(value, 2) == 1;
        }
    }

    // (Int, Int) -> Int
    public class AddFunction extends Function2 {
        public override Object apply(Object arg1, Object arg2) {
            Integer a = (Integer)arg1;
            Integer b = (Integer)arg2;

            return a + b;
        }
    }
}
