@IsTest
private class ConstantFunctorTest {
    @IsTest
    static void testGetConst() {
        ConstantFunctor constFunctor = ConstantFunctor.of('foo');
        System.assertEquals('foo', constFunctor.getConst());
    }

    @IsTest
    static void testFmap() {
        Functor constFunctor = ConstantFunctor.of(123);

        System.assertEquals(
                123,
                ((ConstantFunctor)constFunctor.fmap(Functions.toString())).getConst()
        );
    }

    @IsTest
    static void equalsAndHashCode() {
        System.assertEquals(
                ConstantFunctor.of('123'),
                ConstantFunctor.of('123')
        );

        System.assertEquals(
                System.hashCode('123'),
                ConstantFunctor.of('123').hashCode()
        );
    }
}