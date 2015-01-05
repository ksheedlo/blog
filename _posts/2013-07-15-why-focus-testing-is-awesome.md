---
layout: post
title:  "Why Focus Testing is Awesome"
date:   2013-07-15 23:51:00
excerpt: Unit testing is awesome. One of the great benefits of a test-driven workflow is the ability to iterate rapidly, breaking one thing at a time, refactoring and fixing it while knowing the rest of the code still works...
redirect_from:
  - /2013/07/15/why-focus-testing-is-awesome.html
---

Unit testing is awesome. One of the great benefits of a test-driven workflow is
the ability to iterate rapidly, breaking one thing at a time, refactoring and
fixing it while knowing the rest of the code still works. A common problem
engineers have with test-driven workflows is the time it takes to run them. Even
though well-designed unit tests should run on the order of milliseconds, large
projects can have thousands of them. Such large test suites can run into the
tens of seconds, 
[more than long enough to break your attention](http://www.guardian.co.uk/media-network/media-network-blog/2012/mar/19/attention-span-internet-consumer).

As engineers, we have a variety of ways to deal with this problem. One popular
strategy is to run tests continuously in the background whenever a file changes.
However, this still gives you delayed feedback. One interesting alternative is
called **focus testing** (or *exclusive testing*). In a focus test run, you
selectively run only the specific tests that are relevant to the part of the
code that you're working on.  Where unit test runs are fast, focus test runs are
instantaneous. The five seconds that you save waiting for the results to come
back could be the difference between staying engaged with the task or flipping
over to check Reddit or your email. Extrapolated over a typical workday, it
could even be the difference between staying in the zone for hours or not
getting much done at all. 

Out of the box today,
[Mocha](http://visionmedia.github.io/mocha/#exclusive-tests) and
[Karma](http://karma-runner.github.io/0.8/index.html) both support focus
testing. Both are BDD frameworks for Javascript with a similar syntax. In Mocha,
focus tests look like so:

```js
describe('A focus test', function () {
  it.only('should run', function () {
    ...
  });

  it('should not run', function () {
    ...
  });
});
```

And the same test suite in Karma:

```js
describe('A focus test', function () {
  iit('should run', function () {
    ...
  });

  it('should not run', function () {
    ...
  });
});
```

Each includes a corresponding mode for test suites. Mocha uses `describe.only`
and Karma uses `ddescribe`. A recent 
[GitHub thread](https://github.com/pivotal/jasmine/pull/181) I participated in
shows the controversy over which style is better. I have a slight preference for
the more terse Karma syntax.

It's worth pointing out that focus tests are not something you should see in
someone else's code base (unless you're pair programming), or share with other
people. They decrease life-suck in development, but should be turned off when
you do a build or you won't get the benefit of all the awesome tests you've
accumulated over time. Fortunately, there are [automated
tools](https://github.com/btford/grunt-ddescribe-iit) (credit to Brian Ford) to
make sure you don't run focus tests in your build. In the future, test runners
could add a flag to accomplish this, and you might run `karma --no-focus` on
your CI build.

TL;DR - Focus testing is a huge timesaver. It can make your testing story 1000
times faster in development. Try it! Just keep it out of your build.
