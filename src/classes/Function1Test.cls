@IsTest
public class Function1Test {
    static Function1 plusOne = new PlusOneFunction();
    static Function1 toString = Functions.toString();

    @IsTest
    static void basicFunctionUsage() {
        System.assertEquals(3, plusOne.apply(2));
        System.assertEquals('3', toString.apply(3));
    }

    @IsTest
    static void functionComposition() {
        System.assertEquals(
                '4',
                toString
                        .compose(plusOne)
                        .compose(plusOne)
                        .apply(2));
    }

    @IsTest
    static void functionPipeline() {
        System.assertEquals(
                '5',
                plusOne
                        .andThen(plusOne)
                        .andThen(plusOne)
                        .andThen(toString)
                        .apply(2)
        );
    }

    public class PlusOneFunction extends Function1 {
        public override Object apply(Object arg) {
            Integer firstArg = (Integer)arg;
            return firstArg + 1;
        }
    }
}
