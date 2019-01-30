public class ConstantFunctor implements Functor{
    public static ConstantFunctor of(Object value) {
        return new ConstantFunctor(value);
    }

    final Object value;

    ConstantFunctor(Object value) {
        this.value = value;
    }

    public Object getConst() {
        return value;
    }

    public Functor fmap(Function1 function) {
        return this;
    }

    public Boolean equals(Object obj) {
        return obj instanceof ConstantFunctor
                ? System.equals(value, ((ConstantFunctor)obj).value)
                : false;
    }

    public override Integer hashCode() {
        return System.hashCode(value);
    }

}