---
layout: post
title: 'Return of investment on automatic testing'
date: 2017-06-19
---
So, why do we write tests? We do write tests because it allows us to finish the development quicker. By writing tests we achieve with less effort the point where the software we build does what it has to do. How?

Well, as you type code you are introducing defects into it. We are humans and we suck at being concentrated 8 hours a day, specially after lunch! We do introduce defects.

These defects have some probability to manifest as a program failure and when they manifest it has a cost:

* The failure is communicated to you.
* You have to debug to find the defect.
* You have to fix the defect.
* This fix may have an impact on other parts of your code. We are typing code, so we may introduce new defects (with its associated cost) by fixing this one.
* Move the fix to production.
* ...

So the cost of a defect is something like: `defect_cost = probability_of_manifesting x fixing_cost`

Having an automated test suite allows you to do a lot of testing at any moment by just hitting a button. And this gives several advantages:

* Make bug fixes and check that the fix didn't break anything else (...that is covered by your test suite)
* When your changes break something, you know exactly what was the cause: the code you changed a moment ago. Without tests, the new defect could go unnoticed for some time and imply the costs associated to defects already mentioned.
* Reorganize your code to simplify the evolution of the development and check that everything (...that is covered by your tests suite) still works.

So, tests on one hand save us from defect costs. But on the other hand they introduce also a cost: the cost of writing and maintaining the test. Then, is it beneficial to write tests? How many?

I dare say it is always beneficial to write the first test: the champion of all tests.

## The first test

Normally, the cost of creating a test does not escalate with time. We can think of it as a constant `test_cost`.

When we write a test, we add one _test_cost_ to the cost account. In exchange, we will find several of the defects with high _probability_of_manifesting_. That means: we write a test in half an hour and we save hours of debugging. Sounds beneficial.

## The other tests

Then we write a second test: we add again one _test_cost_ to the cost account. But in exchange we don't find so many defects as before because they were already found by the first test. So the benefit of writing this tests is lower. Still, we may find defects and save some debugging hours.

But the benefit is lower each time because there are less defects and they are harder to find. And this goes on and on and eventually the cost of creating a test is greater than the cost that we save by having the test. It does not mean that there are no defects in our code. It just mean that the probability for these remaining defects to manifest is low and they are more expensive to find now than later *if* they manifest in production.

Note that I am not taking into account costs related to the business consequences of a failure. In some extreme cases the software failure may lead to losing clients, some people dying, etc. I omitted these costs in the defect equation for simplicity but it is something to take into account. Thus, if a failure has grave consequences to you, you should invest a lot on testing it. Obvious. 

