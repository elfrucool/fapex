public abstract class Function2 {
    public abstract Object apply(Object arg1, Object arg2);

    public Function1 apply(Object arg1) {
        return new CurriedFunction2(arg1, this);
    }

    public Function2 andThen(Function1 nextFunction) {
        return new ComposedFunction2(this, nextFunction);
    }

    public class CurriedFunction2 extends Function1 {
        final Object arg1;
        final Function2 originalFunction;

        CurriedFunction2(Object arg1, Function2 originalFunction) {
            this.arg1 = arg1;
            this.originalFunction = originalFunction;
        }

        public override Object apply(Object arg) {
            return originalFunction.apply(arg1, arg);
        }
    }

    public class ComposedFunction2 extends Function2 {
        final Function1 nextFunction;
        final Function2 firstFunction;

        ComposedFunction2(Function2 firstFunction, Function1 nextFunction) {
            this.firstFunction = firstFunction;
            this.nextFunction = nextFunction;
        }

        public override Object apply(Object arg1, Object arg2) {
            return nextFunction.apply(firstFunction.apply(arg1, arg2));
        }
    }
}