// class (Functor f) => Applicative f where
//      pure :: a -> f a
//      (<*>) :: f (a -> b) -> f a -> f b -- (<*>) is named `apply'
//      liftA2 :: (a -> b -> c) -> f a -> f b -> f c
public interface Applicative extends Functor {
    // it just returns a new applicative holding the arg regardless
    // of what the previous value was.
    // pure :: a -> f a
    Applicative pure(Object arg);

    // it applies the function given inside the given applicative to
    // the value hold in the existing applicative.
    // In Haskell, apply function name is (<*>), and its definition is:
    // (<*>) :: f (a -> b) -> f a -> f b
    Applicative apply(Applicative ap);

    // given a function and two applicatives (the existing and another)
    // it applies the function and the result is contained in an applicative
    Applicative liftA2(Function2 mergeFn, Applicative arg2);
}
