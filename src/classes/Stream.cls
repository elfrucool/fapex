public class Stream implements Monad {
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

    // toMap :: (a -> k) -> (a -> v) -> Map k v -> a -> Map k v
    public static Function2 toMap(Function1 keyFunction, Function1 valueFunction) {
        return new ToMapFunction(keyFunction, valueFunction);
    }

    // groupBy :: (a -> k) -> (a -> v) -> [v] -> Map k [v] -> a -> Map k [v]
    public static Function2 groupBy(Function1 keyFunction, Function1 valueFunction, List<Object> listTemplate) {
        return new GroupByFunction(keyFunction, valueFunction, listTemplate);
    }

    static SingletonStreamFunction wrap() {
        return new SingletonStreamFunction();
    }

    static FilterFunction filterFunction(Function1 predicate) {
        return new FilterFunction(predicate);
    }

    final List<Object> items;

    // maybeTransformFunction :: Maybe (a -> Stream b)
    final Maybe maybeTransformFunction;

    Stream(List<Object> items, Maybe maybeTransformFunction) {
        this.items = items;
        this.maybeTransformFunction = maybeTransformFunction;
    }

    public List<Object> toList() {
        return toList(new List<Object>());
    }

    public List<Object> toList(List<Object> template) {
        if (maybeTransformFunction.isPresent()) {
            return (List<Object>) foldLeft(Functions.appendToList(), template);
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
                        .fmap(Functions.applyArgToFunction().apply(oldValue))
                        .getOrDefault(Stream.ofValue(oldValue));

        return transformedStream.toList();
    }

    public Stream pure(Object arg) {
        return Stream.ofValue(arg);
    }

    public Stream apply(Applicative ap) { // ap must be Stream
        return bind(new StreamApplicativeFunction((Stream)ap));
    }

    public Stream liftA2(Function2 mergeFn, Applicative ap) { // ap must be Stream
        return fmap(mergeFn.curry()).apply((Stream)ap);
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

    // Stream a -> Stream (a -> b) -> Stream b
    public class StreamApplicativeFunction extends Function1 {
        final Stream ap;

        StreamApplicativeFunction(Stream ap) {
            this.ap = ap;
        }

        public override Object apply(Object arg) {
            // containedFn :: a -> b
            Function1 containedFn = (Function1) arg;
            return ap.fmap(containedFn);
        }
    }

    // ToMapFunction :: (a -> k) -> (a -> v) -> Map k v -> a -> Map k v
    public class ToMapFunction extends Function2 {
        final Function1 keyFunction;
        final Function1 valueFunction;

        ToMapFunction(Function1 keyFunction, Function1 valueFunction) {
            this.keyFunction = keyFunction;
            this.valueFunction = valueFunction;
        }

        public override Object apply(Object arg1, Object arg2) {
            ((Map<Object, Object>)arg1).put(keyFunction.apply(arg2), valueFunction.apply(arg2));

            return arg1;
        }
    }

    // GrpupByFunction :: (a -> k) -> (a -> v) -> [v] -> Map k [v] -> a -> Map k [v]
    public class GroupByFunction extends Function2 {
        final Function1 keyFunction;
        final Function1 valueFunction;
        final List<Object> listTemplate;

        GroupByFunction(Function1 keyFunction, Function1 valueFunction, List<Object> listTemplate) {
            this.keyFunction = keyFunction;
            this.valueFunction = valueFunction;
            this.listTemplate = listTemplate;
        }

        public override Object apply(Object arg1, Object arg2) {
            Object key = keyFunction.apply(arg2);

            Map<Object, List<Object>> result = (Map<Object, List<Object>>) arg1;

            if (!result.containsKey(key)) {
                result.put(key, listTemplate.clone());
            }

            result.get(key).add(valueFunction.apply(arg2));

            return arg1;
        }
    }
}
