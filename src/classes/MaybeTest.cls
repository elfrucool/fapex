@IsTest
private class MaybeTest {
    @IsTest
    static void maybeCanBeNothingOrJustValue() {
        Maybe nothing = Maybe.Nothing;
        System.assert(nothing != null);

        Maybe just123 = Maybe.Just(123);
        System.assert(just123 != null);
    }

    @IsTest
    static void equalsDependsOnValue() {
        System.assertEquals(Maybe.Just(123), Maybe.Just(123));
    }

    @IsTest
    static void hashCodeIsZeroForNothingOrTheValueHashCode() {
        System.assertEquals(0, Maybe.Nothing.hashCode());
        System.assertEquals(System.hashCode('foo'), Maybe.Just('foo').hashCode());
    }

    @IsTest
    static void canBeBuiltFromAnyValueIfNullThenNothing() {
        System.assertEquals(Maybe.Nothing, Maybe.of(null));
        System.assertEquals(Maybe.Just(123), Maybe.of(123));
    }

    @IsTest
    static void maybeIsAFunctor() {
        System.assertEquals(Maybe.Nothing, Maybe.Nothing.fmap(Functions.toString()));
        System.assertEquals(Maybe.of('123'), Maybe.of(123).fmap(Functions.toString()));
    }

    @IsTest
    static void maybeIsAnApplicative() {
        System.assertEquals(Maybe.of(123), Maybe.Nothing.pure(123));
        System.assertEquals(Maybe.of(123), Maybe.of('foo').pure(123));

        System.assertEquals(Maybe.Nothing, Maybe.Nothing.apply(Maybe.of(Functions.toString())));
        System.assertEquals(Maybe.Nothing, Maybe.of(123).apply(Maybe.Nothing));
        System.assertEquals(Maybe.of('123'), Maybe.of(123).apply(Maybe.of(Functions.toString())));

        System.assertEquals(Maybe.Nothing, Maybe.Nothing.liftA2(Functions.concatenateString(), Maybe.of('123')));
        System.assertEquals(Maybe.Nothing, Maybe.of('123').liftA2(Functions.concatenateString(), Maybe.Nothing));
        System.assertEquals(Maybe.of('123foo'), Maybe.of('123').liftA2(Functions.concatenateString(), Maybe.of('foo')));
    }

    @IsTest
    static void maybeIsAMonad() {
        System.assertEquals(Maybe.Nothing, Maybe.Nothing.bind(Maybe.ofFunction()));
        System.assertEquals(Maybe.of('123'), Maybe.of(123).bind(Maybe.ofFunction().compose(Functions.toString())));
    }

    @IsTest
    static void testingPresenceOfValue() {
        System.assertEquals(false, Maybe.Nothing.isPresent());
        System.assertEquals(true, Maybe.of(123).isPresent());
    }

    @IsTest
    static void getOrDefault() {
        System.assertEquals(123, Maybe.of(123).getOrDefault(5678));
        System.assertEquals(123, Maybe.Nothing.getOrDefault(123));
    }

    @IsTest
    static void getOrError() {
        System.assertEquals(123, Maybe.of(123).getOrError());

        try {
            Maybe.Nothing.getOrError();
        } catch (Maybe.NoSuchElementException e) {
            System.assertEquals('Missing value in Nothing type', e.getMessage());
        }
    }

    @IsTest
    static void orElseJust() {
        System.assertEquals(Maybe.of(123), Maybe.of(123).orElseJust('foo'));
        System.assertEquals(Maybe.of('foo'), Maybe.Nothing.orElseJust('foo'));
    }
}