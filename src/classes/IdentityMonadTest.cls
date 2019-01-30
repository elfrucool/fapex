@IsTest
private class IdentityMonadTest {
    static final Function2 add = new AddFunction();

    @IsTest
    static void testRunIdentity() {
        IdentityMonad identityMonad = IdentityMonad.of(123);

        System.assertEquals(123, identityMonad.runIdentity());
    }

    @IsTest
    static void testFunctor() {
        Functor identity = IdentityMonad.of(123);

        System.assertEquals(
                '123',
                ((IdentityMonad)identity.fmap(Functions.toString())).runIdentity()
        );
    }

    @IsTest
    static void testApplicative() {
        Applicative identityWithValue = IdentityMonad.of(123);

        System.assertEquals(
                'foo',
                ((IdentityMonad) identityWithValue.pure('foo')).runIdentity()
        );

        Applicative identityWithFunction = IdentityMonad.of(Functions.toString());

        System.assertEquals(
                '123',
                ((IdentityMonad)identityWithFunction.apply(identityWithValue))
                        .runIdentity()
        );

        System.assertEquals(
                234,
                ((IdentityMonad)identityWithValue.liftA2(add, IdentityMonad.of(111)))
                        .runIdentity()
        );
    }

    @IsTest
    static void testMonad() {
        Monad identity = IdentityMonad.of(123);

        System.assertEquals(
                '123',
                ((IdentityMonad)identity.bind(IdentityMonad.ofFn().compose(Functions.toString()))).runIdentity()
        );
    }

    @IsTest
    static void equalsAndHashCode() {
        System.assertEquals(
                IdentityMonad.of('foo'),
                IdentityMonad.of('foo')
        );

        System.assertEquals(
                System.hashCode('foo'),
                IdentityMonad.of('foo').hashCode()
        );
    }

    // (+): Int -> Int -> Int
    class AddFunction extends Function2 {
        public override Object apply(Object arg1, Object arg2) {
            return ((Integer)arg1) + ((Integer)arg2);
        }
    }
}