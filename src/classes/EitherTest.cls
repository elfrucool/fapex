@IsTest
private class EitherTest {
    // STRING_LENGTH_FUNCTION :: String -> Int
    static final Function1 STRING_LENGTH_FUNCTION = new StringLengthFunction();

    // MULTIPLY_BY_THREE_FUNCTION :: Int -> Int
    static final Function1 MULTIPLY_BY_THREE_FUNCTION = new MultiplyByThreeFunction();

    // BIND_TO_STRING_FUNCTION :: a -> Either l a
    static final Function1 BIND_TO_STRING_FUNCTION = new BindToStringFunction();

    // throwingExFn :: ex -> a -> a -- will throw ex
    static Function1 throwingExFn(Exception exceptionToThrow) {
        return new ThrowingExceptionFunction(exceptionToThrow);
    }

    @IsTest
    static void eitherCanBeLeftOrRight() {
        Either left = Either.Left('foo');
        System.assert(left.isLeft(), 'left should be left');
        System.assert(!left.isRight(), 'left should not be right');

        Either right = Either.Right(123);
        System.assert(right.isRight(), 'right should be right');
        System.assert(!right.isLeft(), 'right should not be left');
    }

    @IsTest
    static void equalsDependsOnTypeAndValue() {
        Either left1 = Either.Left('foo');
        Either left2 = Either.Left('bar');

        System.assertEquals(left1, Either.Left('foo'));
        System.assert(!left1.equals(null), 'Null should not be equal to ' + left1);
        System.assert(!left1.equals('foo'), 'String is not the either ' + left1);
        System.assert(!left1.equals(Either.Right(123)), 'left is not right');
        System.assertNotEquals(left1, left2, left1 + ' is not ' + left2);

        Either right1 = Either.Right('foo');
        Either right2 = Either.Right('bar');

        System.assertEquals(right1, Either.Right('foo'));
        System.assert(!right1.equals(null), 'Null should not be equal to ' + right1);
        System.assert(!right1.equals('foo'), 'String is not the either ' + right1);
        System.assert(!right1.equals(Either.Left(123)), 'right is not left');
        System.assertNotEquals(right1, right2, right1 + ' is not ' + right2);
    }

    @IsTest
    static void hashCodeDependsOnTypeAndValue() {
        Either left1 = Either.Left('foo');
        Either left2 = Either.Left('bar');

        System.assertEquals(left1.hashCode(), Either.Left('foo').hashCode());
        System.assertNotEquals(left1.hashCode(), 'foo'.hashCode(),
                'not the same hashCode as the contained value');
        System.assertNotEquals(left1.hashCode(), Either.Right('foo').hashCode(),
                'left does not have the same hashCode as right');
        System.assertNotEquals(left1.hashCode(), left2.hashCode(), left1 + ' has different hashCode than ' + left2);

        Either right1 = Either.Right('foo');
        Either right2 = Either.Right('bar');

        System.assertEquals(right1.hashCode(), Either.Right('foo').hashCode());
        System.assertNotEquals(right1.hashCode(), 'foo'.hashCode(),
                'not the same hashCode as the contained value');
        System.assertNotEquals(right1.hashCode(), Either.Left('foo').hashCode(),
                'right does not have the same hashCode as left');
        System.assertNotEquals(right1.hashCode(), right2.hashCode(), right1 + ' has different hashCode than ' + right2);
    }

    @IsTest
    static void eitherMethodReducesEitherTypeToSingleValue() {
        System.assertEquals(9, Either.Right(3).either(STRING_LENGTH_FUNCTION, MULTIPLY_BY_THREE_FUNCTION));

        System.assertEquals(3, Either.Left('foo').either(STRING_LENGTH_FUNCTION, MULTIPLY_BY_THREE_FUNCTION));

        System.assertEquals(
                9, Either.eitherFn(STRING_LENGTH_FUNCTION, MULTIPLY_BY_THREE_FUNCTION).apply(Either.Right(3))
        );

        System.assertEquals(
                3, Either.eitherFn(STRING_LENGTH_FUNCTION, MULTIPLY_BY_THREE_FUNCTION).apply(Either.Left('foo'))
        );
    }

    @IsTest
    static void canRetrieveValues() {
        System.assertEquals(Maybe.Nothing, Either.Left('foo').getRightValue());
        System.assertEquals(Maybe.of('foo'), Either.Right('foo').getRightValue());

        System.assertEquals(Maybe.Nothing, Either.Right('foo').getLeftValue());
        System.assertEquals(Maybe.of('foo'), Either.Left('foo').getLeftValue());
    }

    @IsTest
    static void eitherIsFunctor() {
        System.assertEquals(Either.Left('error'), Either.Left('error').fmap(Functions.toString()));
        System.assertEquals(Either.Right('123'), Either.Right(123).fmap(Functions.toString()));

        System.assertEquals(Either.Right('123'), Either.fmapFn(Functions.toString()).apply(Either.Right(123)));
    }

    @IsTest
    static void eitherIsApplicative() {
        // pure
        System.assertEquals(Either.Right(123), Either.Right('foo').pure(123));
        System.assertEquals(Either.Right(123), Either.Left('hello').pure(123));

        // apply
        System.assertEquals(Either.Left('error'), Either.Left('error').apply(Either.Right(123)));
        System.assertEquals(Either.Left('error'), Either.Right(Functions.toString()).apply(Either.Left('error')));
        System.assertEquals(Either.Right('123'), Either.Right(Functions.toString()).apply(Either.Right(123)));

        // liftA2
        System.assertEquals(
                Either.Left('error'), Either.Left('error').liftA2(Functions.concatenateString(), Either.Right('bar'))
        );
        System.assertEquals(
                Either.Left('error'), Either.Right('foo').liftA2(Functions.concatenateString(), Either.Left('error'))
        );
        System.assertEquals(
                Either.Right('foobar'), Either.Right('foo').liftA2(Functions.concatenateString(), Either.Right('bar'))
        );
        System.assertEquals(
                Either.Right('foobar'),
                Either.liftA2Fn(Functions.concatenateString()).apply(Either.Right('foo'), Either.Right('bar'))
        );
    }

    @IsTest
    static void eitherIsMonad() {
        System.assertEquals(Either.Left('error'), Either.Left('error').bind(BIND_TO_STRING_FUNCTION));
        System.assertEquals(Either.Right('123'), Either.Right(123).bind(BIND_TO_STRING_FUNCTION));

        System.assertEquals(Either.Right('123'), Either.bindFn(BIND_TO_STRING_FUNCTION).apply(Either.Right(123)));
    }

    @IsTest
    static void flipChangesRightToLeftAndLeftToRight() {
        System.assertEquals(Either.Left(123), Either.Right(123).flip());
        System.assertEquals(Either.Right(123), Either.Left(123).flip());
        System.assertEquals(Either.Left(123), Either.flipFn().apply(Either.Right(123)));
    }

    @IsTest
    static void tryFnDealsWithExceptions() {
        EitherTest.MyException exceptionThrown = new MyException();

        Function1 functionWrapped = Either.tryFn(throwingExFn(exceptionThrown));

        Either wrapedResult = (Either) functionWrapped.apply('foo');

        System.assertEquals(
                // cannot compare exceptions directly, comparing string representation
                Either.Left('MyException:[]: Script-thrown exception'),
                wrapedResult
                        .flip() // want to transform left side
                        .fmap(Functions.toString())
                        .flip() // back to original either
        );
    }

    class MyException extends Exception {}

    // StringLengthFunction :: String -> Int
    class StringLengthFunction extends Function1 {
        public override Object apply(Object arg) {
            return ((String) arg).length();
        }
    }

    // MultiplyByThreeFunction :: Int -> Int
    class MultiplyByThreeFunction extends Function1 {
        public override Object apply(Object arg) {
            return ((Integer) arg) * 3;
        }
    }

    // BindToStringFunction :: a -> Either l a
    class BindToStringFunction extends Function1 {
        public override Object apply(Object arg) {
            return Either.Right(Functions.toString().apply(arg));
        }
    }

    // ThrowingExceptionFunction :: ex -> a -> a -- will throw ex
    class ThrowingExceptionFunction extends Function1 {
        final Exception exceptionToThrow;

        ThrowingExceptionFunction(Exception exceptionToThrow) {
            this.exceptionToThrow = exceptionToThrow;
        }

        public override Object apply(Object arg) {
            throw exceptionToThrow;
        }
    }
}