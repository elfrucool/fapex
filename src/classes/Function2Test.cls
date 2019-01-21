@IsTest
public class Function2Test {
    static Function2 plus = new PlusFunction();
    static Function1 toString = Functions.toString();

    @IsTest
    static void basicFunctionUsage() {
        System.assertEquals(5, plus.apply(2, 3));
    }

    @IsTest
    static void currying() {
        System.assertEquals(
                5,
                plus.apply(2)
                        .apply(3)
        );
    }

    @IsTest
    static void pipeline() {
        System.assertEquals(
                '5',
                plus.andThen(toString)
                        .apply(2, 3)
        );
    }

    public class PlusFunction extends Function2 {
        public override Object apply(Object arg1, Object arg2) {
            Integer a = (Integer)arg1;
            Integer b = (Integer)arg2;

            return a + b;
        }
    }
}