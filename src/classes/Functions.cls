/**
 * some generic useful functions.
 */
public class Functions {
    static final Functions.IdentityFunction IDENTITY_FUNCTION = new IdentityFunction();
    static final Functions.ToStringFunction TO_STRING_FUNCTION = new ToStringFunction();
    static final Functions.ConcatenateStringFunction CONCATENATE_STRING_FUNCTION = new ConcatenateStringFunction();
    static final Functions.ApplyArgToFunction APPLY_ARG_TO_FUNCTION = new ApplyArgToFunction();
    static final Functions.AppendToListFunction APPEND_TO_LIST_FUNCTION = new AppendToListFunction();

    // b -> a -> b
    public static Function1 constant(Object value) {
        return new ConstantFunction(value);
    }

    // a -> a
    public static Function1 identity() {
        return IDENTITY_FUNCTION;
    }

    // a -> String
    public static Function1 toString() {
        return TO_STRING_FUNCTION;
    }

    // String -> SObject -> a
    public static Function1 getSObjectField(String fieldName) {
        return new GetSObjectField(fieldName);
    }

    // String -> SObject -> [SObject]
    public static Function1 getSObjectChildren(String fieldName) {
        return new GetSObjectChildren(fieldName);
    }

    // a -> a -> Boolean
    public static Function1 isEqualToPredicate(Object expected) {
        return new IsEqualToPredicate(expected);
    }

    // String -> String -> String
    public static Function2 concatenateString() {
        return CONCATENATE_STRING_FUNCTION;
    }

    // a -> (a -> b) -> b
    public static Function2 applyArgToFunction() {
        return APPLY_ARG_TO_FUNCTION;
    }

    // [a] -> a -> [a]
    public static Function2 appendToList() {
        return APPEND_TO_LIST_FUNCTION;
    }

    // b -> a -> b
    public class ConstantFunction extends Function1 {
        final Object value;

        ConstantFunction(Object value) {
            this.value = value;
        }

        public override Object apply(Object arg) {
            return value;
        }
    }

    // a -> a
    public class IdentityFunction extends Function1 {
        public override Object apply(Object arg) {
            return arg;
        }
    }

    // a -> String
    public class ToStringFunction extends Function1 {
        public override Object apply(Object arg) {
            return String.valueOf(arg);
        }
    }

    // a -> a -> Boolean
    public class IsEqualToPredicate extends Function1 {
        final Object expected;

        IsEqualToPredicate(Object expected) {
            this.expected = expected;
        }

        public override Object apply(Object arg) {
            return System.equals(expected, arg);
        }
    }

    // String -> String -> String
    public class ConcatenateStringFunction extends Function2 {
        public override Object apply(Object arg1, Object arg2) {
            String s1 = (String)arg1;
            String s2 = (String)arg2;

            return s1 + s2;
        }
    }

    // String -> SObject -> a
    public class GetSObjectField extends Function1 {
        final String fieldName;

        GetSObjectField(String fieldName) {
            this.fieldName = fieldName;
        }

        public override Object apply(Object arg) {
            SObject sobj = (SObject)arg;
            return sobj.get(fieldName);
        }
    }

    // String -> SObject -> [SObject]
    public class GetSObjectChildren extends Function1 {
        final String fieldName;

        GetSObjectChildren(String fieldName) {
            this.fieldName = fieldName;
        }

        public override Object apply(Object arg) {
            SObject obj = (SObject)arg;
            return obj.getSObjects(fieldName);
        }
    }

    // a -> (a -> b) -> b
    public class ApplyArgToFunction extends Function2 {
        public override Object apply(Object arg1, Object arg2) {
            return ((Function1)arg2).apply(arg1);
        }
    }

    // [a] -> a -> [a]
    public class AppendToListFunction extends Function2 {
        public override Object apply(Object arg1, Object arg2) {
            List<Object> originalList = (List<Object>) arg1;

            List<Object> modifiedList = new List<Object>(originalList);
            modifiedList.add(arg2);

            return modifiedList;
        }
    }
}
