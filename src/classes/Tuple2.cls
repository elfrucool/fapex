public class Tuple2 {
    // OF_FN :: a -> b -> (a,b)
    static final Function2 OF_FN = new OfFunction();

    // SWAP_FN :: (a,b) -> (b,a)
    static final Function1 SWAP_FN = new SwapFunction();

    // ofFn :: a -> b -> (a,b)
    public static Function2 ofFn() {
        return OF_FN;
    }

    // swapFn :: (a,b) -> (b,a)
    public static Function1 swapFn() {
        return SWAP_FN;
    }

    // foldFn :: (a -> b -> c) -> (a,b) -> c
    public static Function1 foldFn(Function2 foldFunction) {
        return new FoldFunction(foldFunction);
    }

    // fmapFstFn :: (a -> c) -> (a,b) -> (c,a)
    public static Function1 fmapFstFn(Function1 function) {
        return new FmapFstFunction(function);
    }

    // bindFstFn :: (a -> (c,d)) -> (a,b) -> (c,d)
    public static Function1 bindFstFn(Function1 function) {
        return new BindFstFunction(function);
    }

    // fmapSndFn :: (b -> c) -> (a,b) -> (a,c)
    public static Function1 fmapSndFn(Function1 function) {
        return new FmapSndFunction(function);
    }

    // bindSndFn :: (b -> (c,d)) -> (a,b) -> (c,d)
    public static Function1 bindSndFn(Function1 function) {
        return new BindSndFunction(function);
    }

    // fromFn :: (a -> b) -> (a -> c) -> a -> (b,c)
    public static Function1 fromFn(Function1 fstFunction, Function1 sndFunction) {
        return new FromFunction(fstFunction, sndFunction);
    }

    public static Tuple2 of(Object first, Object second) {
        return new Tuple2(first, second);
    }

    final Object first;
    final Object second;

    Tuple2(Object first, Object second) {
        this.first = first;
        this.second = second;
    }

    public Object fst() {
        return first;
    }

    public Object snd() {
        return second;
    }

    public Tuple2 swap() {
        return of(second, first);
    }

    public Object fold(Function2 foldFunction) {
        return foldFunction.apply(first, second);
    }

    public Tuple2 fmapFst(Function1 function) {
        return of(function.apply(first), second);
    }

    public Tuple2 bindFst(Function1 function) {
        return (Tuple2) function.apply(first);
    }

    public Tuple2 fmapSnd(Function1 function) {
        return of(first, function.apply(second));
    }

    public Tuple2 bindSnd(Function1 function) {
        return (Tuple2) function.apply(second);
    }

    public Boolean equals(Object obj) {
        return obj instanceof Tuple2 &&
                System.equals(first, ((Tuple2)obj).first) &&
                System.equals(second, ((Tuple2)obj).second);
    }

    public override Integer hashCode() {
        return System.hashCode(first) + System.hashCode(second);
    }

    public override String toString() {
        return '(' + first + ',' + second + ')';
    }

    class OfFunction extends Function2 {
        public override Object apply(Object arg1, Object arg2) {
            return Tuple2.of(arg1, arg2);
        }
    }

    class SwapFunction extends Function1 {
        public override Object apply(Object arg) {
            return ((Tuple2)arg).swap();
        }
    }

    class FoldFunction extends Function1 {
        final Function2 foldFunction;

        FoldFunction(Function2 foldFunction) {
            this.foldFunction = foldFunction;
        }

        public override Object apply(Object arg) {
            Tuple2 tuple = (Tuple2)arg;
            return foldFunction.apply(tuple.fst(), tuple.snd());
        }
    }

    class FmapFstFunction extends Function1 {
        final Function1 function;

        FmapFstFunction(Function1 function) {
            this.function = function;
        }

        public override Object apply(Object arg) {
            Tuple2 tuple = (Tuple2)arg;
            return tuple.fmapFst(function);
        }
    }

    class FmapSndFunction extends Function1 {
        final Function1 function;

        FmapSndFunction(Function1 function) {
            this.function = function;
        }

        public override Object apply(Object arg) {
            Tuple2 tuple = (Tuple2)arg;
            return tuple.fmapSnd(function);
        }
    }

    class FromFunction extends Function1 {
        final Function1 fstFunction;
        final Function1 sndFunction;

        FromFunction(Function1 fstFunction, Function1 sndFunction) {
            this.fstFunction = fstFunction;
            this.sndFunction = sndFunction;
        }

        public override Object apply(Object arg) {
            return Tuple2.of(fstFunction.apply(arg), sndFunction.apply(arg));
        }
    }

    class BindFstFunction extends Function1 {
        final Function1 function;

        BindFstFunction(Function1 function) {
            this.function = function;
        }

        public override Object apply(Object arg) {
            return ((Tuple2)arg).bindFst(function);
        }
    }

    class BindSndFunction extends Function1 {
        final Function1 function;

        BindSndFunction(Function1 function) {
            this.function = function;
        }

        public override Object apply(Object arg) {
            return ((Tuple2)arg).bindSnd(function);
        }
    }
}