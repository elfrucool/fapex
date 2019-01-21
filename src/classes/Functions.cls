/**
 * some generic useful functions.
 */
public class Functions {
    public static Function1 constant(Object value) {
        return new ConstantFunction(value);
    }

    public static Function1 identity() {
        return new IdentityFunction();
    }

    public static Function1 toString() {
        return new ToStringFunction();
    }

    public static Function1 getSObjectField(String fieldName) {
        return new GetSObjectField(fieldName);
    }

    public static Function1 getSObjectChildren(String fieldName) {
        return new GetSObjectChildren(fieldName);
    }

    public static Function1 isEqualToPredicate(Object expected) {
        return new IsEqualToPredicate(expected);
    }

    public static Function2 concatenateString() {
        return new ConcatenateStringFunction();
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
}
