public class Stream implements Functor {
    public static Stream of(List<Object> items) {
        return new Stream(items, Maybe.Nothing);
    }

    public static Stream ofValue(Object value) {
        return of(new List<Object>{value});
    }

    // ofFn :: [a] -> Stream a
    public static Function1 ofFn() {
        return new StreamOfFunction();
    }

    // bindFn :: (a -> Stream b) -> Stream a -> Stream b
    public static Function1 bindFn(Function1 function) {
        return new BindFunction(function);
    }

    static SingletonStreamFunction wrap() {
        return new SingletonStreamFunction();
    }

    static FilterFunction filterFunction(Function1 predicate) {
        return new FilterFunction(predicate);
    }

    final List<Object> items;
    // maybeTransformFunction :: Maybe Function1
    final Maybe maybeTransformFunction;

    Stream(List<Object> items, Maybe maybeTransformFunction) {
        this.items = items;
        this.maybeTransformFunction = maybeTransformFunction;
    }

    public List<Object> toList() {
        if (maybeTransformFunction.isPresent()) {
            Function1 transformFunction = (Function1)maybeTransformFunction.getOrError();

            List<Object> returnedValues = new List<Object>();

            for (Object item : items) {
                returnedValues.addAll(((Stream)transformFunction.apply(item)).toList());
            }

            return returnedValues;
        }

        return items;
    }

    // function type: a -> a
    public Stream fmap(Function1 function) {
        return bind(function.andThen(wrap()));
    }

    // function type: a -> Stream a
    public Stream bind(Function1 function) {
        Maybe maybeBoundFunction =
                maybeTransformFunction
                        .fmap(Function1.andThenFn(bindFn(function))) // bindFn: recursive definition, be careful
                        .orElseJust(function); // end recursion point

        return new Stream(items, maybeBoundFunction);
    }

    // function type: a -> Boolean
    public Stream filter(Function1 predicate) {
        return bind(filterFunction(predicate));
    }

    // function type: (b, a) -> b
    // initial value type: b
    public Object foldLeft(Function2 accumulate, Object initial) {
        Object result = initial;

        for (Object oldValue: items) {
            List<Object> transformedItems = transformSingleItem(oldValue);

            for (Object newValue : transformedItems) {
                result = accumulate.apply(result, newValue);
            }
        }

        return result;
    }

    List<Object> transformSingleItem(Object oldValue) {
        Stream transformedStream =
                (Stream) maybeTransformFunction
                        .fmap(Functions.applyArgToFunction(oldValue))
                        .getOrDefault(Stream.ofValue(oldValue));

        return transformedStream.toList();
    }

    // a -> Stream a
    public class SingletonStreamFunction extends Function1 {
        public override Object apply(Object arg) {
            List<Object> wrapped = new List<Object>();
            wrapped.add(arg);
            return Stream.of(wrapped);
        }
    }

    // a -> Stream a
    public class FilterFunction extends Function1 {
        // a -> Boolean
        private Function1 predicate;

        FilterFunction(Function1 predicate) {
            this.predicate = predicate;
        }

        public override Object apply(Object arg) {
            List<Object> result = new List<Object>();

            if ((Boolean)predicate.apply(arg)) {
                result.add(arg);
            }

            return Stream.of(result);
        }
    }

    // (a -> Stream b) -> Stream a -> Stream b
    public class BindFunction extends Function1 {
        final Function1 function;

        BindFunction(Function1 function) {
            this.function = function;
        }

        public override Object apply(Object arg) {
            return ((Stream)arg).bind(function);
        }
    }

    // [a] -> Stream a
    public class StreamOfFunction extends Function1 {
        public override Object apply(Object arg) {
            return Stream.of((List<Object>)arg);
        }
    }
}
