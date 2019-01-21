public class Stream implements Functor {
    public static Stream of(List<Object> items) {
        return new Stream(items, wrap());
    }

    static SingletonListFunction wrap() {
        return new SingletonListFunction();
    }

    static ForEachApplyFunction foreEachApply(Function1 function) {
        return new ForEachApplyFunction(function);
    }

    static FlattenListFunction flattenList() {
        return new FlattenListFunction();
    }

    static FilterFunction filterFunction(Function1 predicate) {
        return new FilterFunction(predicate);
    }

    final List<Object> items;
    final Function1 transform;

    Stream(List<Object> items, Function1 transform) {
        this.items = items;
        this.transform = transform;
    }

    public List<Object> toList() {
        List<Object> returnedValues = new List<Object>();

        for (Object item: items) {
            returnedValues.addAll((List<Object>)transform.apply(item));
        }

        return returnedValues;
    }

    // function type: a -> a
    public Stream fmap(Function1 function) {
        return bind(function.andThen(wrap()));
    }

    // function type: a -> [a]
    public Stream bind(Function1 function) {
        return new Stream(
                items,
                transform.andThen(foreEachApply(function)).andThen(flattenList())
        );
    }

    // function type: a -> Boolean
    public Stream filter(Function1 predicate) {
        return bind(filterFunction(predicate));
    }

    // function type: (b, a) -> b
    // initial value type: b
    public Object foldLeft(Function2 accumulate, Object initial) {
        List<Object> transformedItems = toList();

        Object result = initial;

        for (Object newValue: transformedItems) {
            result = accumulate.apply(result, newValue);
        }

        return result;
    }

    // a -> [a]
    public class SingletonListFunction extends Function1 {
        public override Object apply(Object arg) {
            List<Object> wrapped = new List<Object>();
            wrapped.add(arg);
            return wrapped;
        }
    }

    // (a -> b) -> [a] -> [b]
    public class ForEachApplyFunction extends Function1 {
        final Function1 function;

        ForEachApplyFunction(Function1 function) {
            this.function = function;
        }

        public override Object apply(Object arg) {
            List<Object> input = (List<Object>)arg;
            List<Object> output = new List<Object>();

            for (Object i : input) {
                output.add(function.apply(i));
            }

            return output;
        }
    }

    // [[a]] -> [a]
    public class FlattenListFunction extends Function1 {
        public override Object apply(Object arg) {
            // SFDC doesn't know how to cast List<List<Object>>
            List<Object> input = (List<Object>)arg;
            List<Object> output = new List<Object>();

            for (Object chunk: input) {
                // need to split cast in two steps (see above explanation)
                output.addAll((List<Object>)chunk);
            }

            return output;
        }
    }

    // [a] -> [a]
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

            return result;
        }
    }
}
