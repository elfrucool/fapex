public abstract class Function1 {
    // static compose :: (b -> c) -> (a -> b) -> (a -> c)
    public static Function1 composeFn(Function1 innerFn) {
        return new DeferredComposedFunction(innerFn);
    }

    // static pipe :: (a -> b) -> (b -> c) -> (a -> c)
    public static Function1 andThenFn(Function1 innerFn) {
        return new DeferredPipedFunction(innerFn);
    }

    public abstract Object apply(Object arg);

    public Function1 compose(Function1 innerFn) {
        return new ComposedFunction(this, innerFn);
    }

    public Function1 andThen(Function1 outerFn) {
        return new ComposedFunction(outerFn, this);
    }

    public class ComposedFunction extends Function1 {
        final Function1 outerFn;
        final Function1 innerFn;

        ComposedFunction(Function1 outerFn, Function1 innerFn) {
            this.outerFn = outerFn;
            this.innerFn = innerFn;
        }

        public override Object apply(Object arg) {
            return outerFn.apply(innerFn.apply(arg));
        }
    }

    public class DeferredComposedFunction extends Function1 {
        final Function1 innerFn;

        DeferredComposedFunction(Function1 innerFn) {
            this.innerFn = innerFn;
        }

        public override Object apply(Object arg) {
            return ((Function1)arg).compose(innerFn);
        }
    }

    public class DeferredPipedFunction extends Function1 {
        final Function1 outerFn;

        DeferredPipedFunction(Function1 outerFn) {
            this.outerFn = outerFn;
        }

        public override Object apply(Object arg) {
            return ((Function1)arg).andThen(outerFn);
        }
    }
}
