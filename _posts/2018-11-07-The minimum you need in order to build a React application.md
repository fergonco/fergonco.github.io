---
layout: default
title: 'The minimum you need to know in order to build a React application'
date: 2018-11-07
---

# The minimum you need to know in order to build a React application

Recently I had to build a small React interface with a bit of time pressure. The problem was that I didn't know anything about React so I had to learn quickly. Normally I like to read the documentation in depth but this time I decided to focus on coding and just look the documentation as I get stuck. As a result, what I learned is "the minimum you need in order to know to build a React application". Let's go.

The application consisted in two tabs, each one showing a click counter that is initialized in response to a (faked) asynchronous query. [Like this](/react-post/v7/index.html).

The whole thing took 8 hours to build. Hopefully this post can save you that time!

The post is organized like this:

1. Disclaimer
2. Creating a React project.
3. Understanding the concept of component.
4. Building the tabs user interface, where I deal with some practical aspects of using React.

## Disclaimer

This quick tutorial will condense the *essential* information in order to build React applications, but remember that I just dedicated 8h to it. Most of the things I mention here can be plain wrong and there may be important omissions. If you are planning to build some serious application you need additional sources of information, probably the official documentation, which looks quite complete and easy to process.

## Creating a React project

React projects are quite a complex because they put together several different technologies. However, there is a project called [*create-react-app*]() that configures a lot of things automatically. You just need to install it and run it in order to create your React project:

{% highlight bash %}
npm install -g create-react-app
create-react-app my-app
{% endhighlight %}

[Here](https://github.com/facebook/create-react-app#whats-included) is the list of the things it configures.

The following command runs your project:

{% highlight bash %}
npm start
{% endhighlight %}

The created project contains no configuration files. Probably all is defined by default in some dependency. However, it is possible to [*eject*](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#npm-run-eject) from this situation and get all the configuration files in your project:

{% highlight bash %}
npm run eject
{% endhighlight %}

Finally, you just run

{% highlight bash %}
npm run build
{% endhighlight %}

In order to generate the production ready artifacts in a *build* folder. The build command outputs useful information, for example that you have to put the path of your application in the *homepage* attribute in *package.json*. In my case, [the application](/react-post/index.html) is installed in the "/react-post" path, so I have to set it to "/react-post":

{% highlight json %}
{
  "name": "react-post",
  "version": "0.1.0",
  "private": true,
  "homepage": "/react-post",
  "dependencies": {
    ...
  }
  ...
}
{% endhighlight %}

## React components

Basically React allows you to reuse components for web interfaces. A React component will have some logic and will produce some HTML+CSS code *when the time comes*.

All starts by a call to *ReactDOM.render(&lt;JSXexpression&gt;, &lt;DOMelement&gt;)*, where the *DOMelement* is the element where you want to put the result of the JSX expression. If this element is a div with id = "root", you just call:

{% highlight javascript %}
document.getElementById("root");
{% endhighlight %}

JSX is an extension to Javascript that allows you to write something like HTML inside your Javascript code. Thus, JSX expressions allow you to define the DOM structure that your component will produce.

So in this initial call, the JSXExpression will be a reference to the React component that you want to render, for example:

{% highlight javascript %}
ReactDOM.render(<MyComponent/>, document.getElementById("root"));
{% endhighlight %}

This will make React create an instance of *MyComponent* and make it "render" some contents that will be added to the *root* element in the DOM.

To summarize, we are instantiating components by means of JSX expressions and adding them to the DOM.

Let's see how a component looks like.

### Defining your components

Components are subclasses of *React.Component*.

{% highlight javascript %}
import React from 'react';

class MyComponent extends React.Component {

}
{% endhighlight %}

As such, they inherit a *render()* method, in charge of returning the contents that will be added to the DOM:

{% highlight javascript %}
import React from 'react';

class MyComponent extends React.Component {

    render() {
        return <span>hello world</span>;
    }
}
{% endhighlight %}

The *render* method will be also using JSX expressions for this purpose.

(By the way, yes: the syntax coloring in this post gets all messed up with the JSX expressions)

In order to ~~produce some content~~ *render*, the component needs information. There are two sources of information for a component:

* **State**: will contain information of the current state of the component, like checked or not checked in case of a checkbox.
* **Properties**: used to customize your component instance, defined in JSX expressions when including the instance of the component.

Let's see each one of them in detail.

#### State

State can be defined in the constructor, for example:

{% highlight javascript %}
import React from 'react';
import MUIDataTable from 'mui-datatables';

class MyComponent extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            counter: 0
        };
    }

    render() {
        return <span>Hello world clicked {this.state.counter} times</span>;
    }
}
{% endhighlight %}

Note how in the previous example the constructor defines a *state* attribute and the render method has an expression between curly braces referencing it.

As a subclass of React.Component, your components inherit several methods to deal with the state, I know about:

* *setState*, which merges the given parameter with the existing state.
* *replaceState*, which sets the given parameter as the new state.

These methods will be called in response to an event, an asynchronous call response, etc. and will trigger a *render* process. It is important to remember that **it is the call to these methods which is forcing a render**. If we set directly the *state* attribute the component will not be rendered.

In the next example, we update the counter in the *increaseCounter* method:

{% highlight javascript %}
import React from 'react';
import MUIDataTable from 'mui-datatables';

class MyComponent extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            counter: 0
        };
    }

    increaseCounter = ()=>{
        this.setState({
            counter: this.state.counter + 1
        });
    }

    render() {
        return <span onClick={this.increaseCounter}>Hello world clicked {this.state.counter} times</span>;
    }
}
{% endhighlight %}

Note how it is using the arrow function syntax. This is in order to have a proper reference in *this*.

#### Properties

The other type of information your component may need in order to render are *properties* which are defined in the references to your component inside JSX expressions. Indeed, in the previous example we are already sending some properties to the *span* control: we are setting the *onClick* property and the content of the span, which is the *children* property.

However, our control is not receiving any property, because the JSX expression including it (in the *ReactDOM.render* call) is not specifying them. We could parameterize the counter message, like this:

{% highlight javascript %}
render() {
    return <span onClick={this.increaseCounter}>{this.props.message}{this.state.counter}</span>;
}
{% endhighlight %}

Thus we could include our control in the call to *ReactDOM.render* specifying the *message* property like this:

{% highlight javascript %}
ReactDOM.render(<MyComponent message="Hallo Welt Zähler: "/>, document.getElementById('root'));
{% endhighlight %}

[Here](https://github.com/fergonco/react-post/blob/375ab9e96c3d19998cdfbf9baf918ebbcb99661a/src/index.js) is the code so far. And [here](/react-post/v1/index.html) is a demo.

BTW, React components can also be a function, but just ignore this and do not very scared if you see one.

## Counters inside tabs

Now we want to put the counters inside tabs and show one or the other depending on the selected tab. Selecting one tab would show one counter and selecting the other tab would show us the other counter. Easy, right? well, not that much. 

### Material-UI

I didn't do any research on this, so there may be better options. However [Material UI](https://github.com/mui-org/material-ui) it seems a rather popular component repository, which follows the Google *Material*'s design, whatever that is. Cool components to reuse, in any case.

The MaterialUI Tabs [demo page](https://material-ui.com/demos/tabs/) has links to the GitHub repository with the code, which is useful to understand how to use the components.

### The tabs

Install Material UI:

{% highlight bash %}
npm install @material-ui/core
{% endhighlight %}

and add the tabs in the *ReactDOM.render()* call in *src/index.js*:

{% highlight javascript %}
import Tabs from '@material-ui/core/Tabs';
import Tab from '@material-ui/core/Tab';

[...]

ReactDOM.render((
    <Tabs value="c1">
        <Tab label="Counter 1" value="c1"/>
        <Tab label="Counter 2" value="c2"/>
    </Tabs>
), document.getElementById('root'));
{% endhighlight %}

Basically we nest two *Tab* components inside a *Tabs* component. The *value* property in the *Tab* instances is used as identifier and the one in the *Tabs* instance points to the *Tab* that we want to select. So far we are not placing our component in the tabs.

[Here](https://github.com/fergonco/react-post/blob/4944e4b29f1af2014cae2c0de015d3fdd2335472/src/index.js) is the code so far and [here](/react-post/v2/index.html) is a demo.

### Selecting the tabs

If you see the resulting application you will notice that the selected tab cannot be changed. This is because the *Tabs* *value* property is hardcoded to "c1". We could set the *value* property with a variable and add an *onChange* property to update the variable value. Then we should force the component to re-*render*. The easiest way to force this *render* process is to actually make this variable the state of a parent component, so that we can use the *setState* method to force the rendering of the tree under it.

{% highlight javascript %}
class TabsContainer extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            selectedTab: "c1"
        }
    }

    changeTab = (event, value)=> {
        this.setState({
            selectedTab:value
        });
    }

    render() {
        return (
            <Tabs value={this.state.selectedTab} onChange={this.changeTab}>
                <Tab label="Counter 1" value="c1"/>
                <Tab label="Counter 2" value="c2"/>
            </Tabs>
        );
    }
}

ReactDOM.render(<TabsContainer/>, document.getElementById('root'));
{% endhighlight %}

Now, when *changeTab* is invoked in response to a click on a tab, the state of *TabsContainer* will be updated, and that will force the component (and the children tabs) to render again.

The code can be found [here](https://github.com/fergonco/react-post/blob/780cd504a82585c6111590eb6cdd2f33d3fc790b/src/index.js) and [here](/react-post/v3/index.html) is a demo.

### Showing one span or the other

Now we want to show one counter or the other depending on the selected *Tab*. It would be nice if this is done as children of the *Tab* components, but it is not. So basically you set a component under it and show it depending on the selected tab.

You will see the following suggested a lot:

{% highlight javascript %}
render() {
    return (
        <div>
            <Tabs value={this.state.selectedTab} onChange={this.changeTab}>
                <Tab label="Counter 1" value="c1"/>
                <Tab label="Counter 2" value="c2"/>
            </Tabs>
            {this.state.selectedTab === "c1" && <MyComponent message="First counter: "/>}
            {this.state.selectedTab === "c2" && <MyComponent message="Second counter: "/>}
        </div>
    );
}
{% endhighlight %}

Where all the controls are wrapped inside a *div* (Looks like JSX expressions must evaluate to a single component) and the *MyComponent* instances are evaluated (between curly braces) conditionally to the value of *this.state.selectedTab*. This is however a bad idea because a new component gets instantiated on each render. If you see the resulting application, changing tabs makes the counters start at zero every time (because it is a new one).

The code can be found [here](https://github.com/fergonco/react-post/blob/dbace48eed05bb9d33c7b47e5ba14d5c4832045b/src/index.js) and [here](/react-post/v4/index.html) is a demo.

This approach is specially dangerous if the component is listening some event, or if there is a reference to it somewhere in the application, because we will be creating a lot of components that we no longer use whose memory cannot be freed because they are still referenced, a.k.a. memory leak.

Instead we want to instantiate them only once and show them conditionally. We will be using a *.hidden* class like this:

{% highlight css %}
.hidden {
    display: none;
}
{% endhighlight %}

and we will embed the counters in *div*s, that will be shown depending on the *selectedTab* state:

{% highlight javascript %}
render() {
    return (
        <div>
            <Tabs value={this.state.selectedTab} onChange={this.changeTab}>
                <Tab label="Counter 1" value="c1"/>
                <Tab label="Counter 2" value="c2"/>
            </Tabs>
            <div className={this.state.selectedTab !== "c1"?'hidden':''}>
                <MyComponent message="First counter: "/>
            </div>
            <div className={this.state.selectedTab !== "c2"?'hidden':''}>
                <MyComponent message="Second counter: "/>
            </div>
        </div>
    );
}
{% endhighlight %}

Thus, react will be intelligent enough to reuse the instances of *MyComponent* created at each execution of *render*, which is great from the performance point of view and also not so sensitive to memory leaks as the previous approach.

The code can be found [here](https://github.com/fergonco/react-post/blob/6da2e3772b27184f3892ca911bcc5c8256a7f60f/src/index.js) and [here](/react-post/v5/index.html) is a demo. Note that now the change of tab does not cause the counter to reinitialize.

### Getting some information into the control after an asynchronous call

Finally, sometimes your component needs some information that will come when the component instance is already created and rendered. This is the case, for example, if we want to initialize our counters with some value obtained from a web service. Let's mimic that with a simple timeout firing 2s after the application starts:

{% highlight javascript %}
setTimeout(()=>{
    let c1 = 10;
    let c2 = 5;

    // How do we reach our component instances rendered in the dom?

}, 2000);
{% endhighlight %}

How do we reach our component instances rendered in the dom?

The only and dangerous approach I have found is to use an event, for example at the *document* level. Let's say we use "counter1-init" as event for the first counter and "counter2-init" as event for the second one. Our timeout would look like this:

{% highlight javascript %}
setTimeout(()=>{
    let c1 = 10;
    let c2 = 5;

    document.dispatchEvent(new CustomEvent("counter1-init", {
        detail: c1
    }));
    document.dispatchEvent(new CustomEvent("counter2-init", {
        detail: c2
    }));
}, 2000);
{% endhighlight %}

And our components should listen for these events, for example in the constructor:

{% highlight javascript %}
class MyComponent extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            counter: 0
        };
        this.listener = (event) => {
            this.setState({
                counter: event.detail
            });
        }

        document.addEventListener(this.props.eventName, this.listener);
    }

[...]

{% endhighlight %}

Note that we have two events: *counter1-init* and *counter2-init*, so the event name to register our component instance is parameterized through the *eventName* property. In the call to *addEventListener* we use the *eventName* property, which has to be set when the component is instantiated in the JSX expression in the *TabsContainer.render()* method:

{% highlight javascript %}
[...]
<div className={this.state.selectedTab !== "c1"?'hidden':''}>
    <MyComponent eventName="counter1-init" message="First counter: "/>
</div>
<div className={this.state.selectedTab !== "c2"?'hidden':''}>
    <MyComponent eventName="counter2-init" message="Second counter: "/>
</div>
[...]
{% endhighlight %}

The code can be found [here](https://github.com/fergonco/react-post/blob/ed271755b1c483a3b745f234691e4bb97b677e6f/src/index.js) and [here](/react-post/v6/index.html) is a demo.

#### Components life cycle 

I said before that this approach is dangerous because we are keeping a reference to our components (and we rely in React to instantiate and discard them). If React decides to create new instances in each render and discard old ones, as we saw previously, we'll have a memory leak.

To avoid this risk we have to remove our listener when our component is no longer used. This can be done using the *componentDidMount* and *componentWillUnmount* methods inherited from *React.Component*. These methods are called when the component is inserted to and removed from the tree, respectively. We can add the listener in *componentDidMount* and remove it in *componentWillUmount*, like this:

{% highlight javascript %}
class MyComponent extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            counter: 0
        };
    }

    componentDidMount() {
        this.listener = (event) => {
            this.setState({
                counter: event.detail
            });
        }

        document.addEventListener(this.props.eventName, this.listener);
    }

    componentWillUnmount() {
        document.removeEventListener(this.props.eventName, this.listener);
        this.listener = null;
    }

    increaseCounter = ()=>{
        this.setState({
            counter: this.state.counter + 1
        });
    }

    render() {
        return <span onClick={this.increaseCounter}>{this.props.message}{this.state.counter}</span>;
    }

}
{% endhighlight %}

The code can be found [here](https://github.com/fergonco/react-post/blob/87161e324f0f00e90501767fae180312b49b06f4/src/index.js) and [here](/react-post/v7/index.html) is a demo.

I did some tests with the previous syntax:

{% highlight javascript %}
{this.state.selectedTab === "c1" && <MyComponent message="First counter: "/>}
{% endhighlight %}

which creates a new *MyComponent* instance on each call to *render()*, and there is still a memory leak. Why? I don't know. In any case the approach for me to follow is not to use that syntax and try to stick with the same instance of my component as much as possible. I'll do an update if I learn why is it leaking memory.
