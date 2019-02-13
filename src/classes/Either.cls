// data Either l r = Left l | Right r
public abstract class Either implements Monad {
    static final Either.FlipFunction FLIP_FUNCTION = new FlipFunction();

    public static Either Left(Object value) {
        return new Left(value);
    }

    public static Either Right(Object value) {
        return new Right(value);
    }

    // eitherFn :: (a -> c) -> (b -> c) -> Either a b -> c
    public static Function1 eitherFn(Function1 leftFn, Function1 rightFn) {
        return new EitherFunction(leftFn, rightFn);
    }

    // fmapFn :: (a -> b) -> Either l a -> Either l b
    public static Function1 fmapFn(Function1 fmapFunction) {
        return new FmapFunction(fmapFunction);
    }

    // liftA2Fn :: (a -> b -> c) -> Either l a -> Either l b -> Either l c
    public static Function2 liftA2Fn(Function2 liftA2Function) {
        return new LiftA2Function(liftA2Function);
    }

    // bindFn :: (a -> Either l b) -> Either l a -> Either l b
    public static Function1 bindFn(Function1 bindFunction) {
        return new BindFunction(bindFunction);
    }

    // flipFn :: Either l r -> Either r l
    public static Function1 flipFn() {
        return FLIP_FUNCTION;
    }

    // tryFn :: (a -> b) -> a -> Either e b
    public static Function1 tryFn(Function1 functionThatMightFail) {
        return new TryFunction(functionThatMightFail);
    }

    public abstract Boolean isLeft();

    public abstract Boolean isRight();

    public abstract Object either(Function1 leftFn, Function1 rightFn);

    // getRightValue :: Maybe l
    public abstract Maybe getRightValue();

    // getLeftValue :: Maybe r
    public abstract Maybe getLeftValue();

    // fmap :: (a -> b) -> Either l a -> Either l b
    public abstract Either fmap(Function1 function);

    // pure :: a -> Either l a
    public Either pure(Object obj) {
        return Either.Right(obj);
    }

    // apply :: Either l (a -> b) -> Either l a -> Either l b
    public Either apply(Applicative ap) { // hack to make the compiler happy
        return this.apply((Either) ap);
    }

    // apply :: Either l (a -> b) -> Either l a -> Either l b
    public abstract Either apply(Either ap);

    // liftA2 :: (a -> b -> c) -> Either l a -> Either l b -> Either l c
    public Either liftA2(Function2 mergeFn, Applicative arg2) {
        return this.liftA2(mergeFn, (Either) arg2);
    }

    // liftA2 :: (a -> b -> c) -> Either l a -> Either l b -> Either l c
    // liftA2 f e1 e2 = f <$> e1 <*> e2
    // -- in other words: liftA2 f e1 e2 = apply e2 (fmap f e1)
    public Either liftA2(Function2 mergeFn, Either arg2) {
        return fmap(mergeFn.curry()).apply(arg2);
    }

    // (>>=) :: m a -> (a -> m b) -> m b
    public abstract Either bind(Function1 aToMonadB);

    // flip :: Either l r -> Either r l
    public abstract Either flip();

    public class Left extends Either {
        final Object value;

        Left(Object value) {
            this.value = value;
        }

        public override String toString() {
            return 'Left{' + value + '}';
        }

        public Boolean equals(Object obj) {
            return obj instanceof Left
                    && System.equals(value, ((Left) obj).value);
        }

        public override Integer hashCode() {
            return System.hashCode('Left') + System.hashCode(value);
        }

        public override Boolean isLeft() {
            return true;
        }

        public override Boolean isRight() {
            return false;
        }

        public override Object either(Function1 leftFn, Function1 rightFn) {
            return leftFn.apply(value);
        }

        public override Maybe getRightValue() {
            return Maybe.Nothing;
        }

        public override Maybe getLeftValue() {
            return Maybe.of(value);
        }

        public override Either fmap(Function1 function) {
            return this;
        }

        public override Either apply(Either ap) {
            return this;
        }

        public override Either bind(Function1 aToMonadB) {
            return this;
        }

        public override Either flip() {
            return Right(value);
        }
    }

    public class Right extends Either {
        final Object value;

        Right(Object value) {
            this.value = value;
        }

        public override String toString() {
            return 'Right{' + value + '}';
        }

        public Boolean equals(Object obj) {
            return obj instanceof Right
                    && System.equals(value, ((Right) obj).value);
        }

        public override Integer hashCode() {
            return System.hashCode('Right') + System.hashCode(value);
        }

        public override Boolean isLeft() {
            return false;
        }

        public override Boolean isRight() {
            return true;
        }

        public override Object either(Function1 leftFn, Function1 rightFn) {
            return rightFn.apply(value);
        }

        public override Maybe getRightValue() {
            return Maybe.of(value);
        }

        public override Maybe getLeftValue() {
            return Maybe.Nothing;
        }

        public override Either fmap(Function1 function) {
            return Either.Right(function.apply(value));
        }

        public override Either apply(Either ap) {
            return ap.fmap((Function1) value);
        }

        public override Either bind(Function1 aToMonadB) {
            return (Either) aToMonadB.apply(value);
        }

        public override Either flip() {
            return Left(value);
        }
    }

    // eitherFn :: (a -> c) -> (b -> c) -> Either a b -> c
    class EitherFunction extends Function1 {
        final Function1 leftFunction;
        final Function1 rightFunction;

        EitherFunction(Function1 leftFn, Function1 rightFn) {
            this.leftFunction = leftFn;
            this.rightFunction = rightFn;
        }

        public override Object apply(Object arg) {
            return ((Either) arg).either(leftFunction, rightFunction);
        }
    }

    // fmapFn :: (a -> b) -> Either l a -> Either l b
    class FmapFunction extends Function1 {
        final Function1 fmapFunction;

        FmapFunction(Function1 fmapFunction) {
            this.fmapFunction = fmapFunction;
        }

        public override Object apply(Object arg) {
            return ((Either) arg).fmap(fmapFunction);
        }
    }

    // liftA2Fn :: (a -> b -> c) -> Either l a -> Either l b -> Either l c
    class LiftA2Function extends Function2 {
        final Function2 liftA2Function;

        LiftA2Function(Function2 liftA2Function) {
            this.liftA2Function = liftA2Function;
        }

        public override Object apply(Object arg1, Object arg2) {
            return ((Either) arg1).liftA2(liftA2Function, (Either) arg2);
        }
    }

    // bindFn :: (a -> Either l b) -> Either l a -> Either l b
    class BindFunction extends Function1 {
        final Function1 bindFunction;

        BindFunction(Function1 bindFunction) {
            this.bindFunction = bindFunction;
        }

        public override Object apply(Object arg) {
            return ((Either)arg).bind(bindFunction);
        }
    }

    // flipFn :: Either l r -> Either r l
    class FlipFunction extends Function1 {
        public override Object apply(Object arg) {
            return ((Either)arg).flip();
        }
    }

    // tryFn :: (a -> b) -> a -> Either e b
    class TryFunction extends Function1 {
        final Function1 functionThatMightFail;

        TryFunction(Function1 functionThatMightFail) {
            this.functionThatMightFail = functionThatMightFail;
        }

        public override Object apply(Object arg) {
            try {
                return Right(functionThatMightFail.apply(arg));
            } catch (Exception e) {
                return Left(e);
            }
        }
    }
}