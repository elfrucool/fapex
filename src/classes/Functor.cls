// class Functor f where
//      fmap :: (a -> b) -> f a -> f b
public interface Functor {
    Functor fmap(Function1 function);
}
