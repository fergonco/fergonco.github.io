---
layout: post
title: 'I will (almost) never (unit) test again'
date: 2017-06-27
---
Some time ago I wrote about how a memory leak was making a service crash and how I fixed it ([here](http://fergonco.org/2017/03/31/Docker-container-Java-heap-dump-analysis.html) and [here](http://fergonco.org/2017/04/13/Docker-container-Java-heap-dump-analysis-(follow-up))). This process changed (or reverted back) my view on testing and in this post I explain how. Recently I wrote about [the return of investment for automatic testing](http://fergonco.org/2017/06/19/ROI-of-testing.html) and you may want to take a look at it before.

Very early in my career I started doing automatic testing on my projects. In one of them, a SQL interpreter, I remember having a rather disorganized test suite with around 300 functional tests that basically gave SQL scripts to the interpreter and checked the results. There were no unit tests but the suite did its work: the software was stable and regressions were rare even if I did refactor the internals often.

## I am testing wrong!

As years went by I learned that I was doing testing wrong: one is supposed to write unit tests, the tests has to be written before the actual code, there is test driven development, etc. And all of these techniques and methodologies were well founded.

So, among other things, I tried to cover my units (typically Java classes or some Javascript similar) with unit test cases. Then I found that some of my units were not easy to test and that it is an indicator of bad design. I didn't want to have a bad design **so I adapted the units so that they were testable**... until this process happened to introduce a memory leak. How?

## I am testing very wrong indeed!

As usual, I adapted my code in order to make it more testable. I had a *Bug* class that did something with a *javax.persistence.EntityManager*:

```java
public class Bug {

	public void someMethod() {
		EntityManager em = ...;

		// some operation with em
	}
	
}
```

This EntityManager object kept some object references but, as it had a method scope, all could be garbage collected after the method finished.

In order to test it I wanted to be able to use a mocked EntityManager, so I passed it through the constructor:

```java
public class Bug {

	private EntityManager em;

	public Bug(EntityManager em) {
		this.em = em;
	}

	public void someMethod() {
		// some operation with em
	}

}
```

And *voilà*, now the class can be tested but the object references kept by the EntityManager are not freed as long as the *Bug* object lives, which is the whole life of the application.

Silly? Yes. Could it be done otherwise? Yes, for example using dependency injection. But it did happen. And it illustrates that one can introduce bugs in the most subtle ways.

## So now what?

This made me think about my testing workflow, about the nice feeling I had with my functional test suites and about the feeling of wasting resources I have building unit test suites. And I ended up with three reasons not to unit test:

1. Unit tests affect your design. You have to make your code testable. I don't think having testable units leads to the design that is best for the development process because there may be parts of the codebase that do not need a good design. So unit testing is getting on the way to proper design.

2. Unit tests affect your code. Typing code may introduce bugs. For example, the aforementioned memory leak. In this case the cost to fix the defect introduced to make the code testable was quite high.

3. Unit tests require a lot of maintenance. Units evolve a lot and unit tests have to evolve along. Something so common as a simple internal refactoring may make units change a lot, even disappear, which requires a similar action on the test suite. I does not seem interesting to base the test investment on such volatile units. 

The benefit of unit testing is that, at this small scale, they identify very clearly where is the bug and this reduces a lot the time for debugging. But in my experience, unit tests introduce huge costs and are not generally worth. So from now on I will go back to strong functional test suites and I will write unit tests for specially complex units that I think will remain long in the project.
