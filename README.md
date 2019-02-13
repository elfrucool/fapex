# _f_-APEX

Functional Salesforce Apex Library

## Abstract

This library brings to Salesforce Apex programming language the foundation of functional programming (FP). Although it's far from perfect (the author is neither Apex nor FP expert) I hope missing parts could be built on top of it.

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


### Dealing with errors without exceptions

WIP - The `Either` type

### Working with collections

WIP - The `Stream` type

## Components

## Troubleshooting

Check `FunctionsTestUtil.insertAccountWithTwoContacts()` to see if you need to adjust to your validation rules and make tests pass.

## Pending work

There is still **a lot** of pending work, below is a non-exhaustive list:

* Including more category theory types (traversables, foldables, semigroups, monoids, arrows)
* Include a _kind of_ `IO` monad for dealing with database (specially for consolidating database actions)
* Include `Lenses` and/or `Optics` types (either simple or monadic)
* Add more useful generic functions

## Contributing

There are many ways to contribute, for the moment I see these two:

1. ask Salesforce to improve apex:
    - support generics: https://success.salesforce.com/ideaView?id=08730000000aDnYAAU
    - support lambdas: https://success.salesforce.com/ideaView?id=08730000000Dk5sAAC

2. improve the code: (either fork it and create your version or submit a PR)