# _f_-APEX

Functional Salesforce Apex Library

## Abstract

This library brings to Salesforce Apex programming language the foundation of functional programming (FP). Although it's far from perfect (the author is neither Apex nor FP expert) I hope missing parts could be built on top of it.

It is similar to other libraries like [apex-lambda](https://github.com/ipavlic/apex-lambda) and [R.apex](https://github.com/Click-to-Cloud/R.apex) but it tries to be more generic (not just for `SObject` type) and to use strictly functional programming principles (purity, referential transparency, good category theory)

## Installation

Just copy all the `*.cls` files to your org. 

## Usage

Below is a non exhaustive list of possible use cases.

### The basic function

```apex
Function1 addOne = new AddOneFunction();

System.assertEquals(2, addOne.apply(1)); // 1 + 1 = 2

// names ending with `Function' are just a convention
class AddOneFunction extends Function1 {
    public override Object apply(Object arg) {
        return ((Integer)arg) + 1;
    }
}
```

**note** want it type safe? (not casting), ask salesforce to support generics:
- https://success.salesforce.com/ideaView?id=08730000000aDnYAAU

not much but keep reading, the power of FP resides in something called _composition_:

```apex
Function1 multiplyByTwo = new MultiplyByTwoFunction();

System.assertEquals(10, addOne.andThen(multiplyByTwo).apply(4)); // (4 + 1) * 2
System.assertEquals(9, addOne.compose(multiplyByTwo).apply(4)); // (4 * 2) + 1
System.assertEquals(
    '10',
    Functions.getSObjectField('How_Many__c') // My_Object__c.How_Many__c
        .andThen(addOne)                     // How_Many__c + 1
        .andThen(multiplyByTwo)              // (How_Many__c + 1) * 2
        .andThen(Functions.toString())       // everything to string
        .apply(new My_Object__c(How_Many__c = 4))
);

class MultiplyByTwoFunction extends Function1 {
    public override Object apply(Object arg) {
        return ((Integer)arg) * 2;
    }
}
```

Many times you need to group values into a map (either single key->value, or multiple key->[value1, value2...]), `Stream` type comes with two handy functions for this case, now showing the more generic (complex) `groupBy` function:

```apex
List<Tuple2> tuples = new List<Tuple2>{
        Tuple2.of('Bob', 'sales'),
        Tuple2.of('Mary', 'engineering'),
        Tuple2.of('John', 'engineering'),
        Tuple2.of('George', 'management')
};

Map<Object, List<String>> peopleByRole = (Map<Object, List<String>>)
        Stream.of(tuples) // you can do any fmap/bind/filter before the final `foldLeft'
                .foldLeft(
                    Stream.groupBy(Tuple2.sndFn(), Tuple2.fstFn(), new List<String>()),
                    new Map<Object, List<String>>()
                );

System.assertEquals(
        new Map<Object, List<String>>{
                'sales' => new List<String>{ 'Bob' },
                'engineering' => new List<String>{ 'Mary', 'John' },
                'management' => new List<String>{ 'George' }
        },
        peopleByRole
);
```

### Dealing with null values

tired of `null` checks? then check the `Maybe` type out:

#### SObject objects

Without _f_-apex:

```apex
public String getAmountAsString() {
    SomeObject someObj = getValue();
    
    if (someObj != null) {
      Some_Property_1__c someProperty1 = someObj.Some_Property_1__c;
      
      if (someProperty1 != null) {
        Some_Property_2__c someProperty2 = someProperty1.Some_Property_2__c;
        
        if (someProperty2 != null) {
            // list might grow
            Double amount = someProperty2.Amount__c;
            
            return String.valueOf(amount); // or another `if'
        }
      }
    } else {
        return '0.0';
    }
}
```

With _f_-apex:

```apex
public String getAmountAString() {
    return (Double) Maybe.of(getValue()) // SomeObject might be null
            .fmap(Functions.getSObjectField('Some_Property_1__c'))
            .fmap(Functions.getSObjectField('Some_Property_2__c')) 
            .fmap(Functions.getSObjectField('Amount__c'))
            .fmap(Functions.toString())
            .getOrDefault('0.0');
}
// ... no need to define custom functions
```

**note** want it type safe? (not casting), ask salesforce to support generics:
- https://success.salesforce.com/ideaView?id=08730000000aDnYAAU

#### Non SObject objects

It's the same approach but need to define the functions to get the values. It seems counterintuitive at first but it's worth long therm (apart you can define them once and reuse)

Without _f_-apex:

```apex
public String getAmountAsString() {
    SomeObject someObj = getValue();
    
    if (someObj != null) {
      SomeProperty1 someProperty1 = someObj.getSomeProperty1();
      
      if (someProperty1 != null) {
        SomeProperty2 someProperty2 = someProperty1.getSomeProperty2();
        
        if (someProperty2 != null) {
            // list might grow
            Double amount = someProperty2.getAmount();
            
            return String.valueOf(amount); // or another `if'
        }
      }
    } else {
        return '0.0';
    }
}
```

With _f_-apex:

```apex
public String getAmountAsString() {
    return (Double) Maybe.of(getValue()) // SomeObject might be null
            .fmap(new GetSomeProperty1Function()) // build it once, use it everywhere
            .fmap(new GetSomeProperty2Function()) // names ending with `Function' 
            .fmap(new GetAmountFunction())        // are only a convention
            .fmap(Functions.toString()) // have some useful functions
            .getOrDefault('0.0');
}
// ... later in code
public class GetSomeProperty1Function extends Function1 {
    public override Object apply(Object arg) {
        return ((SomeObject)arg).getSomeProperty1();
    }
}
public class GetSomeProperty2Function extends Function1 {
    public override Object apply(Object arg) {
        return ((SomeProperty1)arg).getSomeProperty2();
    }
}
public class GetAmountFunction extends Function1 {
    public override Object apply(Object arg) {
        return ((SomeProperty1)arg).getSomeProperty2();
    }
}
```

**note** want it easier?
- ask salesforce to support lambdas: https://success.salesforce.com/ideaView?id=08730000000Dk5sAAC

### Working with collections

This is one of my favorites, many of the work in apex is working with collections of records, although the `Stream` type is generic enough to work with any type, it's a good fit to work with query results, try to do the same without _f_-apex

```apex
List<MyCoolObject__c> myCoolObjects = [ // Keys__c has values like 'foo,bar,baz'
    SELECT Id, (SELECT Id, Keys__c FROM Children__r)
    FROM MyCoolObject__c
];

List<String> allButFoo =
        Stream.of(myCoolObjects)
            .bind(Functions.getSObjectChildren('Children__r').andThen(Stream.ofFn()))
            .fmap(Functions.getSObjectField('Keys__c'))
            .bind(Functions.split().andThen(Stream.ofFn()))
            .filter(Functions.negate().compose(Functions.isEqualToPredicate('foo')))
            .toList();
```


### Dealing with errors without exceptions (and without early returns)

#### Error handling without early returns

without _f_-apex:

```apex
Response someService(someInput...) {
    Result result1 = getResult1(someInput);
    
    if (!result1.success) {
        return new FailingResponse(result1.errorMessage);
    }
    
    Result result2 = getResult2(result1);
    
    if (!result2.success) {
        return new FailingResponse(result2.errorMessage);
    }
    
    // ....
    
    Result resultN = getResultN(resultM);
    
    if (!resultN.success) {
        return new FailingResponse(resultN.errorMessage);
    }
    
    return new SuccessResponse(resultN);
}
```

with _f_-apex:

```apex
// see the power of function compositio
static final Function1 RESULT_TO_EITHER_FUNCTION = new ResultToEitherFunction(); 
static final Function1 GET_RESULT1_FUNCTION =
    RESULT_TO_EITHER_FUNCTION.compose(new GetResult1Function());
static final Function1 GET_RESULT2_FUNCTION =
    RESULT_TO_EITHER_FUNCTION.compose(new GetResult2Function());
// ...
static final Function1 GET_RESULT_N_FUNCTION =
    RESULT_TO_EITHER_FUNCTION.compose(new GetResultNFunction());
    
Response someService(someInput...) {
    return (Response)Either.Right(someInput)
                .bind(GET_RESULT1_FUNCTION)
                .bind(GET_RESULT2_FUNCTION)
                .bind(...) //
                .bind(GET_RESULT_N_FUNCTION)
                .either(
                    new MakeFailingResponseFunction(),
                    new MakeSuccessResponseFunction()
                );
}

// later in code
class ResultToEitherFunction extends Function1 {
    public override Object apply(Object arg)
        return ((Result)result).succes ? Either.Right(result) : Either.Left(result);
    }
}

class GetResult1Function extends Function1 {
    public override Object apply(Object arg) {
        return ParentClass.getResult1((SomeInput)arg);
    }
}

class GetResult2Function extends Function1 {
    public override Object apply(Object arg) {
        return ParentClass.getResult1((Result)arg);
    }
}

class GetResultNFunction extends Function1 {
    public override Object apply(Object arg) {
        return ParentClass.getResultN((Result)arg);
    }
}

class MakeFailingResponseFunction extends Function1 {
    public override Object apply(Object arg) {
        return new FailingResponse(((Result)arg).errorMessage);
    }
}

class MakeSuccessResponseFunction extends Function1 {
    public override Object apply(Object arg) {
        return new SuccessResponse((Result)arg);
    }
}
```

**note** want it shorter?
- ask salesforce to support lambdas: https://success.salesforce.com/ideaView?id=08730000000Dk5sAAC


#### Error handling without exceptions

Without _f_-apex:

```apex
Response service(SomeInput input) {
    try {
        Result result = getThrowingResult1(input);
        Result result2 = getThrowingResult2(result);
        return new SuccessResponse(result2);
    } catch (Exception1 ex) {
        return new FailingResponse(ex.getMessage());
    } catch (Exception2 ex) {
        return new FailingResponse(ex.getMessage());
    }
}
```

With _f_-apex, we have the `Either.tryFn(Function1 f)` function that performs a `try-catch` and wraps the catched exception in `Either.Left` while the good result is returned in `Either.Right`.

```apex
Response service(SomeInput input) {
    (Response)Either.Right(input)
        .bind(Either.tryFn(GET_THROWING_RESULT1_FUNCTION)) // apply: return getThrowingResult(..)
        .bind(Either.tryFn(GET_THROWING_RESULT2_FUNCTION))
        .either(
            EXCEPTION_TO_FAILING_RESPONSE_FUNCTION,
            SUCCESS_RESPONSE_FUNCTION
        );
}
// define functions similar as above
```

## Components

| Object Type    | Name        | Description                                  |
|----------------|-------------|----------------------------------------------|
| Abstract class | Function1   | The foundation of everything                 |
|                |             | represents a funciton with a single argument |
|                |             | able to be composed or chained               |
| Abstract class | Function2   | Similar to Function1 but with two arguments  |
|                |             | it can be partially applied and curried      |
| Interface      | Functor     | The Functor type                             |
| Interface      | Applicative | The Applicative Functor type                 |
| Interface      | Monad       | The Monad type                               |
| Class          | Maybe       | The Maybe type can hold a value or be empty  |
|                |             | and make transformations in a monadic way    |
| Class          | Either      | The Either type can have a right value or a  |
|                |             | left value (usually representing an error)   |
|                |             | and make transformations in a monadic way    |
| Class          | Stream      | Monading interface for working with lists    |
| Class          | Functions   | A collection of useful functions             |

## Troubleshooting

Check `FunctionsTestUtil.insertAccountWithTwoContacts()` to see if you need to adjust to your validation rules and make tests pass.

## Pending work

There is still **a lot** of pending work, below is a non-exhaustive list:

* Havning N-ary functions instead of `Function1, Function2` with full _partial application/curry_ support.
* Including more category theory types (traversables, foldables, semigroups, monoids, arrows)
* Making `Stream` type even more lazy (thinks like `head, tail, drop, takeWhile` that not evaluate the entire list)
* Include a _kind of_ `IO` monad for dealing with database (specially for consolidating database actions)
* Include `Lenses` and/or `Optics` types (either simple or monadic)
* Add more useful generic functions

## Contributing

There are many ways to contribute, for the moment I see these two:

1. ask Salesforce to improve apex:
    - support generics: https://success.salesforce.com/ideaView?id=08730000000aDnYAAU
    - support lambdas: https://success.salesforce.com/ideaView?id=08730000000Dk5sAAC

2. improve the code: (either fork it and create your version or submit a PR), guidelines:
    - keep functions _pure_ (no observable side effects)
    - keep functions _referentially transparent_ (always returning same output given same input)
    - keep _immutablility_ (do not modify input state, do not modify functions state)
    - do the tests in a way that assert _correct behavior_ not just code coverage