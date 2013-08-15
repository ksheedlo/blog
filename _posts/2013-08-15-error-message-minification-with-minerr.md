---
layout: post
title: "Error Message Minification with MinErr"
date: 2013-08-15 15:00:00
description: How we improved the Angular developer experience with readable minified error messages.
---

With the release of AngularJS 1.2.0rc1, the Angular team announced our new
error message minification service, called MinErr (pronounced "miner"). MinErr
provides more insight to developers about error conditions in their app, while
also reducing code size. To ease the transition, let's take a detailed look at
MinErr and try to answer any questions that might come up.

#### What is MinErr and why did you build it?

Angular has had some cryptic and confusing error messages in the past.

```
Error: 10 $digest iterations reached. Aborting!
    at Object.g.$digest
    at Object.g.$apply
    at Object.d [as invoke]
```

Useful error messages tend to be longer and more detailed, but long error
message string literals don't minify well. Keeping the core small is very
important for Angular, so new developers usually had to go to Google and
StackOverflow to make sense of our terse error messages.

To solve this problem, we built MinErr. MinErr is a set of tools that strip your
error message from the code at compile time and generate detailed documentation
on [docs.angularjs.org](http://docs.angularjs.org). It allows us to provide
detailed error messages with optional interpolated parameters. Using MinErr, the
same `$digest` error shown above produces the following error message (truncated
for readability):

```
[$rootScope:infdig] http://errors.angularjs.org/1.2.0-rc1/$rootScope/infdig?p0=10&p1=%5B%5B...
```

See the [full link](http://docs.angularjs.org/error/$rootScope:infdig?p0=10&p1=%5B%5B%22foo%3B%20newVal:%206%3B%20oldVal:%205%22%5D,%5B%22foo%3B%20newVal:%207%3B%20oldVal:%206%22%5D,%5B%22foo%3B%20newVal:%208%3B%20oldVal:%207%22%5D,%5B%22foo%3B%20newVal:%209%3B%20oldVal:%208%22%5D,%5B%22foo%3B%20newVal:%2010%3B%20oldVal:%209%22%5D%5D)
for an example of what the resulting page looks like on the AngularJS website.

Error messages can be as detailed as necessary without contributing to the
weight of Angular. In fact, implementing MinErr removed over 1KB from the
minified and gzipped build, which saved the cost of approximately two core
components.

#### How do I use it?

You interact with MinErr when an error occurs inside Angular. In a non-minified
build, a MinErr error will log its detailed message to the console,
interpolated with any relevant parameters. In a minified build, it will log a
link. Clicking on the link will send you to a web page with the interpolated
error message along with a detailed description of the error and a Disqus
thread.

#### How do I develop with it?

As a contributor to Angular, you should define your errors in a way that MinErr can
understand. Each error message is identified by a namespace and error code. The
namespace should be chosen by the component, directive or module that the error
occurs in, and should be as specific as possible. For instance, an error in the
`$location` service should have namespace `$location`, and an error in the
`ngRepeat` directive should have namespace `ngRepeat`. The error code should be
a short (4-10 character) string that identifies the error and is unique in the
namespace. Here's a short example using namespace `namespace` and error code
`code`.

```
var namespaceMinErr = minErr('namespace');
throw namespaceMinErr('code', 'long {0} template string', 'interpolated');
```

It's very important to note that **variable naming is significant.** The result
from `minErr('namespace')` must be named `namespaceMinErr`. The compile step
will not notice or possibly mislabel a different variable name.

If the error was defined correctly, the following error message will log in
development:

```
[namespace:code] long interpolated template string
```

In a minified build, the message changes.

```
[namespace:code] http://errors.angularjs.org/1.2.0/namespace/code?p0=interpolated
```

It's also legal to chain the result of the call to `minErr` if there is only one
error code in the namespace, like in the following example. The results are the
same as above.

```
throw minErr('namespace')('code', 'long {0} template string', 'interpolated');
```

After you define a new MinErr error, you need to define a doc file for that
error. For our simple example, the file would be
`docs/content/error/namespace/code.ngdoc`. It might contain the following:

```
@ngdoc error
@name namespace:code
@fullName Example MinErr Error
@description

This error occurs when demonstrating MinErr.

For more information, refer to docs.angularjs.org/error.
```

The build will fail until this file has at least been defined with the
appropriate metadata. You are strongly encouraged to fill in a detailed
description of what the error is along with how to reproduce and fix it. The
build will then generate a page on the website for your new error.

#### Pitfalls

Variable naming is significant when defining and using new error messages.  The
example above explains how to name a `minErr` object.  Make sure to name
`minErr` objects correctly.

The compiler issues a warning when you throw an non-MinErr error. This causes
problems with rethrows. For example,

```
try {
  doSomethingThatMightThrowMinErr();
} catch (e) {
  process(e);
  throw e;  // Warning!
}
```

This will issue a warning, even if we know `e` is always a MinErr. Future
versions of MinErr will use Closure Compiler type annotations to solve this
problem. For now, this is something you need to watch out for.

The `docs` task in Grunt now depends on `minify`. This happens because the
compiler outputs a file with error message template strings and metadata, which
is needed for the `docs` task. This should probably be made explicit in the
Grunt configuration for Angular, but we haven't done it yet. You can be the
first to send a pull request with the fix!  In the meantime, always make sure
you can run `grunt package` without any failures and without introducing any
additional warnings.

#### Compiler Hacking

As part of the implementation of MinErr, we implemented a custom pass in
Google Closure Compiler. As a result, we now have our own custom runner for
Closure Compiler that we can use for doing Angular-specific processing and
analysis. You can fork it [here](https://github.com/angular/ng-closure-runner).
If you have an idea for making production Angular smaller or more convenient to
work with, get in touch with us or send us a pull request!

Of course, if you want to hack on the compiler for Javascript in general, you
should send a patch to
[Closure Compiler on Google Code](https://code.google.com/p/closure-compiler/).

#### What's next?

We'll continue making MinErr better and easier to use. The next release of
MinErr will log the site URL in development mode in addition to the interpolated
error message. We also have planned improvements to the compiler to relax some
of the current usage restrictions.

Please try it out and
[report any issues](https://github.com/angular/angular.js/issues?state=open).
Feel free to send a pull request if you find something that's broken or could
be improved.

Happy error-free hacking from myself and the Angular team!
