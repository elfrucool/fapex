@IsTest
private class Tuple2Test {
    static final Function2 ADD = new AddFunction();
    static final Function1 TO_STRING_AND_ADD_1 = Tuple2.fromFn(Functions.toString(), ADD.apply(1));
    static final Function1 PREPEND_BAR = Functions.concatenateString().apply('bar');
    static final Function1 STRING_LENGTH = new StringLengthFunction();
    static final Function1 LENGTH_AND_PREPEND_BAR =
            Tuple2.fromFn(STRING_LENGTH, PREPEND_BAR);

    @IsTest
    static void tuple2holdsTwoValues() {
        Tuple2 tuple = Tuple2.of(123, 'foo');
        System.assertEquals((Object)123, tuple.fst());
        System.assertEquals((Object)'foo', tuple.snd());
    }

    @IsTest
    static void tuple2canBeBuiltWithFunction() {
        Function2 tupleFn = Tuple2.ofFn();
        Tuple2 tuple = (Tuple2) tupleFn.apply(123, 'foo');
        System.assertEquals((Object)123, tuple.fst());
        System.assertEquals((Object)'foo', tuple.snd());
    }

    @IsTest
    static void fromFn() {
        System.assertEquals(Tuple2.of('123', 124), TO_STRING_AND_ADD_1.apply(123));
        System.assertEquals(Tuple2.of(3, 'barfoo'), LENGTH_AND_PREPEND_BAR.apply('foo'));
    }

    @IsTest
    static void equalsHashCodeAndToString() {
        System.assertEquals('(123,foo)', Tuple2.of(123, 'foo').toString());
        System.assertEquals(Tuple2.of(123, 'foo'), Tuple2.of(123, 'foo'));
        System.assert(!Tuple2.of(123, 'foo').equals('foo'));
        System.assert(!Tuple2.of(123, 'foo').equals((Tuple2)null));
        System.assertNotEquals(Tuple2.of(123, 'foo'), Tuple2.of('foo', 123));
        System.assertNotEquals(Tuple2.of(123, 'foo'), Tuple2.of(1234, 'foo'));
        System.assertNotEquals(Tuple2.of(123, 'foo'), Tuple2.of(123, 'foobar'));
        System.assertEquals(System.hashCode(123) + System.hashCode('foo'), Tuple2.of(123, 'foo').hashCode());
    }

    @IsTest
    static void swap() {
        System.assertEquals(Tuple2.of('foo', 123), Tuple2.of(123, 'foo').swap());
        System.assertEquals(Tuple2.of('foo', 123), Tuple2.swapFn().apply(Tuple2.of(123, 'foo')));
    }

    @IsTest
    static void fold() {
        System.assertEquals('foobar', Tuple2.of('foo', 'bar').fold(Functions.concatenateString()));
        System.assertEquals('foobar', Tuple2.foldFn(Functions.concatenateString()).apply(Tuple2.of('foo', 'bar')));
    }

    @IsTest
    static void fmapFst() {
        System.assertEquals(Tuple2.of('123', 'foo'), Tuple2.of(123, 'foo').fmapFst(Functions.toString()));
        System.assertEquals(Tuple2.of('123', 'foo'),
                Tuple2.fmapFstFn(Functions.toString()).apply(Tuple2.of(123, 'foo')));
    }

    @IsTest
    static void fmapSnd() {
        System.assertEquals(Tuple2.of(123, 'barfoo'), Tuple2.of(123, 'foo').fmapSnd(PREPEND_BAR));
        System.assertEquals(Tuple2.of(123, 'barfoo'), Tuple2.fmapSndFn(PREPEND_BAR).apply(Tuple2.of(123, 'foo')));
    }

    @IsTest
    static void bindFst() {
        System.assertEquals(Tuple2.of('123', 124), Tuple2.of(123, 'foo').bindFst(TO_STRING_AND_ADD_1));
        System.assertEquals(Tuple2.of('123', 124), Tuple2.bindFstFn(TO_STRING_AND_ADD_1).apply(Tuple2.of(123, 'foo')));
    }

    @IsTest
    static void bindSnd() {
        System.assertEquals(Tuple2.of(3, 'barfoo'), Tuple2.of(123, 'foo').bindSnd(LENGTH_AND_PREPEND_BAR));
        System.assertEquals(Tuple2.of(3, 'barfoo'),
                Tuple2.bindSndFn(LENGTH_AND_PREPEND_BAR).apply(Tuple2.of(123, 'foo')));
    }

    // AddFunction :: Int -> Int -> Int
    class AddFunction extends Function2 {
        public override Object apply(Object arg1, Object arg2) {
            return ((Integer)arg1) + ((Integer)arg2);
        }
    }

    // StringLengthFunction :: String -> Int
    class StringLengthFunction extends Function1 {
        public override Object apply(Object arg1) {
            return ((String)arg1).length();
        }
    }
}