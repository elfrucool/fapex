public class IdentityMonad implements Monad {
    public static Function1 ofFn() {
        return new IdentityOfFunction();
    }

    public static IdentityMonad of(Object value) {
        return new IdentityMonad(value);
    }

    final Object value;

    IdentityMonad(Object value) {
        this.value = value;
    }

    public Object runIdentity() {
        return value;
    }

    // fmap :: (a -> b) -> f a -> f b
    public IdentityMonad fmap(Function1 function) {
        return of(function.apply(value));
    }

    // pure :: f a -> f b -> f b
    public IdentityMonad pure(Object arg) {
        return of(arg);
    }

    // apply :: f (a -> b) -> f a -> f b
    public IdentityMonad apply(Applicative ap) {
        return (IdentityMonad) ap.fmap((Function1)value);
    }

    // liftA2 :: (a -> b -> c) -> f a -> f b -> f c
    public IdentityMonad liftA2(Function2 mergeFn, Applicative ap) {
        return pure(mergeFn.apply(value)).apply(ap);
    }

    public IdentityMonad bind(Function1 aToMonadB) {
        return (IdentityMonad) aToMonadB.apply(value);
    }

    public Boolean equals(Object obj) {
        return obj instanceof IdentityMonad
                ? System.equals(value, ((IdentityMonad)obj).value)
                : false;
    }

    public override Integer hashCode() {
        return System.hashCode(value);
    }


    public class IdentityOfFunction extends Function1 {
        public override Object apply(Object arg) {
            return IdentityMonad.of(arg);
        }
    }
}