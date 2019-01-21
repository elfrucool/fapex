// class (Applicative f) => Monad f where
//      (>>=) :: m a -> (a -> m b) -> m b -- known as `bind'
// other methods are irrelevant or redundant
public interface Monad extends Applicative {
    // m a -> (a -> m b) -> m b
    Monad bind(Function1 aToMonadB);
}