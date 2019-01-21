public abstract class Function1 {
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
}
