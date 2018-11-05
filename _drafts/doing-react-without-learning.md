☐ Format the hourly log
☐ Evaluate the memory leak with a production build (better on the project with MUItables).
☐ Spellcheck
☐ Proofread
☐ Publish

# The minimum you need to know to build a React application

Recently I had to build a React interface with a bit of a time pressure so I decided to build it "without learning React". Normally I read the documentation of the tools I work with but in this case it will be different: I will search for the different aspects of React in response to what I need to build a specific application. As a result, what I learned is "the minimum you need to know to build a React application". Let's go.

The application will be two tabs, each one showing a table that is populated in response to an asynchronous query. [Like this](/react-post/index.html).

The whole interface took 8 hours to build. Hopefuly this post can save you that time!

The post is organized this way:

1. Disclaimer
2. Creating a React project.
3. Understanding the concept of component.
4. Building the tabs user interface, where I deal with some practical aspects of using React.
5. Hourly log.

## Disclaimer

This quick tutorial can get you started, but remember that I just dedicated 8h to learn React. Most of the things I mention here can be plain wrong. If you are planning to build some serious site you probably want to read the documentation and see how these concepts fit there.

## Creating a React project

A react project is quite a complex thing, which puts together several different technologies. There is a project called [*create-react-app*]() that puts all this together automatically by typing in the command line this:

{% highlight bash %}
npm install -g create-react-app
create-react-app my-app
{% endhighlight %}

This will create a project with [a lot of things configured on it](https://github.com/facebook/create-react-app#whats-included). The following command runs your project:

{% highlight bash %}
npm start
{% endhighlight %}

The project created contains no configuration file, all is defined by default in some dependency probably. It is possible to [*eject*](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#npm-run-eject) from this situation and get all the configuration files in your project:

{% highlight bash %}
npm run eject
{% endhighlight %}

Finally, you just run *npm run build* in order to get the application built in a *build* folder.

## React components

Basically React allows you to reuse components for web interfaces. A React component will have some logic and will produce some HTML+CSS code *when the time comes*.

All starts by a call to *ReactDOM.render(&lt;JSXexpression&gt;, &lt;DOMelement&gt;)*, where the *DOMelement* is the element where you want to render the result of the JSX expression. If this element is a div with id = "root", you just call:

{% highlight javascript %}
document.getElementById("root");
{% endhighlight %}

JSX is an extension to Javascript that allows you to write something like HTML inside your Javascript code. Thus, JSX expressions allow you to:

- define the DOM structure that you component will produce.
- include in this structure other react components.

So in this initial call, the JSXExpression will be a reference to the React component that you want to render, for example:

{% highlight javascript %}
ReactDOM.render(<MyComponent/>, document.getElementById("root"));
{% endhighlight %}

This will make the framework instantiate a *MyComponent* instance, make it "render" some contents that will be added to the *root* element in the DOM.

So apparently we are instantiating components by means of JSX expressions and adding their *render* output to the DOM. Let's see what a component looks like.

### Defining your components

Components are subclases of *React.Component*.

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

(By the way, yes: the syntax coloring gets all messed up with JSX in this post)

In order ~~to produce some content~~ *render*, the component needs information. There are two sources of information for a component:

* **State**: will contain information of the current state of the component, like checked or not checked in case of a checkbox.
* **Properties**: used to customize your component instance, defined in JSX expressions when including the instance of the component.

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

    increaseCounter = () => {
        this.setState({
            counter: this.state.counter + 1
        });
    }

    render() {
        return <span>Hello world clicked {this.state.counter} times</span>;
    }
}
{% endhighlight %}

Note how in the previous example the constructor defines a state attribute and the render method has an expression between curly braces referencing it.

As a subclass of React.Component, your components inherit several methods to deal with the state, I know about:

* *setState*, which merges the existing state with the given parameter
* *replaceState*, which sets the given parameter as the new state

These methods will be called in response to an event, an asynchronous call response, etc. and will trigger a *render* process. It is important to remember that it is the call to these methods which is forcing a render. If we set directly the *state* attibute the component will not be rendered.

For example, we can count the clicks on the component:

{% highlight javascript %}
increaseCounter = ()=>{
    this.setState({
        counter: this.state.counter + 1
    });
}

render() {
    return <span onClick={this.increaseCounter}>Hello world clicked {this.state.counter} times</span>;
}
{% endhighlight %}

Note how the *increaseCounter* function is using the arrow function syntax. This is order to have a proper reference in *this*. I will not make any further comments on this.

#### Properties

The other type of information your component may need in order to render are *properties* which are defined in the references to your component inside JSX expressions. Indeed, in the previous example we are already sending some properties to the *span* control. We are setting the *onClick* property and the content of the span, which is the *children* property.

However, our control is not receiving any property, because the JSX expression including it (in the *ReactDOM.render* call) is not specifying them. We could let the client code customize the message, like this:

{% highlight javascript %}
render() {
    return <span onClick={this.increaseCounter}>{this.props.message}{this.state.counter}</span>;
}
{% endhighlight %}

Thus we could include our control in the call to *ReactDOM.render* specifying the *message* property like this:

{% highlight javascript %}
ReactDOM.render(<MyComponent message="Hallo Welt Zähler: "/>, document.getElementById('root'));
{% endhighlight %}

BTW, React components can also be a function, but just ignore this and do not very scared if you see one.

## Practical use case

There are two more important concepts that I want to show you, in order to do that we need a slightly more complex example. We want to have two tabs showing two different things. In this example we will be showing two instances of the counter. So, selecting one tab would show one counter and selecting the other tab would show us the other counter. Easy, right? well, not that much. 

### Material-UI

I didn't do any research on this, so there may be better options. However [Material UI](https://github.com/mui-org/material-ui) it seems a rather popular component repository, which follows the Google *Material*'s design, whatever that is. Cool components to reuse, in any case.

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

The code can be found [here](https://github.com/fergonco/react-post/blob/4944e4b29f1af2014cae2c0de015d3fdd2335472/src/index.js).

### Selecting the tabs

If you see the resulting application you will notice that the selected tab cannot be changed. This is because the *Tabs* *value* property is hardcoded to "c1". We could set it with a variable and add an *onChange* property to update the variable value. Then we should force the component to re-*render*. The easiest way to force this *render* process is to actually making this variable the state of a parent component, so that we can use the *setState* method to force the rendering of the tree under it.

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

Now, when *changeTab* is invoked in response to a tab change, the state of TabsContainer will be updated and rendered again, along with the children components Tabs and Tab.

The code can be found [here](https://github.com/fergonco/react-post/blob/780cd504a82585c6111590eb6cdd2f33d3fc790b/src/index.js).

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

Where all the controls are wrapped inside a *div* (you cannot define several components in a JSX expression) and the *MyComponent* instances are evaluated between curly braces conditionally to the value of *this.state.selectedTab*. This is however a bad idea because a new component gets instantiated on each render. If you go the browser and change tabs you will see that the counter starts at zero everytime (because it is a new one).

The code can be found [here](https://github.com/fergonco/react-post/blob/dbace48eed05bb9d33c7b47e5ba14d5c4832045b/src/index.js).

This approach is specially dangerous if the component is listening some event, or in general anybody has a reference to it, because we will be creating a lot of components that we no longer use whose memory cannot be freed because they are still referenced, a.k.a. memory leak.

Instead we want to instantiate them only once and show them conditionally. We will be using a *.hidden* class like this:

{% highlight css %}
.hidden {
    display: none;
}
{% endhighlight %}

and we will embed the counters in divs, that will be shown depending on the *selectedTab* state:

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

Thus, react will be intelligent enough to reuse the instances of *MyComponent* created at each execution of *render*. Which is great from the performance point of view and also not so sensitive to memory leaks as the previous approach.

The code can be found [here](https://github.com/fergonco/react-post/blob/6da2e3772b27184f3892ca911bcc5c8256a7f60f/src/index.js).

### Getting some information into the control after an asynchronous call

Finally, sometimes your component needs some information that will come when the component instance is already created and rendered. This is the case, for example, if we want to initialize our counters with some value obtained from a web service. Let's mimic that with a simple timeout firing 2s after the application starts:

{% highlight javascript %}
setTimeout(()=>{
    let c1 = 10;
    let c2 = 5;

    // How do we reach our component instances rendered in the dom?

}, 2000);
{% endhighlight %}

The only and dangerous approach I have found is to use an event, for example at the document level. Let's say we use "counter1-init" as event for the first counter and "counter2-init" as event for the second one. Our timeout would look like this:

{% highlight javascript %}

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

Note that we have two events: *counter1-init* and *counter2-init*, so the event name to register our component instance is parameterized through properties. In the call to *addEventListener* we use the *eventName* property, which has to be set when the component is instantiated in the JSX expression in the *TabsContainer.render()* method:

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

The code can be found [here](https://github.com/fergonco/react-post/blob/ed271755b1c483a3b745f234691e4bb97b677e6f/src/index.js).

#### Life cycle 

I said before that this approach is dangerous because we are keeping a reference to our components (and we rely in React to instantiate and discard them). If React decides to discard our components in each render, as we saw previously, we'll have a memory leak.

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

The code can be found [here](https://github.com/fergonco/react-post/blob/87161e324f0f00e90501767fae180312b49b06f4/src/index.js).

I did some tests with the previous syntax:

{% highlight javascript %}
{this.state.selectedTab === "c1" && <MyComponent message="First counter: "/>}
{% endhighlight %}

which creates a new *MyComponent* instance on each call to *render()*, and there is still a memory leak. Why? I don't know. It could have something to do with the development mode, or maybe there is something wrong with the code. In any case the approach to follow is not to use that syntax and try to stick with the same instance of my component as much as possible.

## Hourly log

# 1h: went through the tutorial

    Current concept of react: It is a library to reuse web components.

    - How do I create a hello world SPA? Do I create a HTML template and insert react controls? Do I create a root control and all the other react controls nested on it?
    - How do I babelize the result?

# 2h:

    Steps:

        ☑ Try to use one of the material components:
        Install material: https://material-ui.com/

        ☑ Try to use a tab component as the root of my application
            - How do I change the tab? Listening to the onChange event

    Questions:

    ☑ How do I create a hello world SPA? Do I create a HTML template and insert react controls? Do I create a root control and all the other react controls nested on it?
        Both options seem possible. I'll try to go for having a root React component.
    ☐ Does the tab component contain a panel that is changed everytime? it seems it does not.
    ☐ How do I babelize the result?

# long time has passed. I don't remember well the tutorial so I may be missing obvious points

# 3h: 

    I took a look at the code (https://github.com/mui-org/material-ui/blob/master/docs/src/pages/demos/tabs/SimpleTabs.js) for the tabs demo (https://material-ui.com/demos/tabs/) and saw how the SimplaTabs component was holding the index of the selected tab in Tabs.

    I saw as well 

    * how it conditionally showed the component belonging to the selected tab.
    * how it could even be a function!

        function MarketView() {
            return (
                <span>Market</span>
            );
        }

    React components:
    * can have props, which are parameters set on the render method
    * this.props.children is the *innerHTML* of the call
    * have a state, which is hold at the instance level (how is it done with function based components? I don't know, I don't care)
    
    Steps:

        ☑ Embed the Tab component in another component that holds the tab status
        ☑ Make the Tab component pick the status from there
        ☑ add a panel that changes on tab changes.
        ☑ Put a grid on the component. We use MUI-Datatables over the ones of material-ui because of the capability to specify dynamically the data

    Questions:

        ☑ How do I create a hello world SPA? Do I create a HTML template and insert react controls? Do I create a root control and all the other react controls nested on it?
            Both options seem possible. I'll try to go for having a root React component.
        ☑ Does the tab component contain a panel that is changed everytime? it seems it does not.
        ☐ Can we make a REST GET query and populate the data accordingly (rows and columns)? We will not be able to populate the columns if the request contains no entity (could this be useful https://www.django-rest-framework.org/tutorial/7-schemas-and-client-libraries/?).
        ☐ How do I babelize the result?

# 5h: 
    
    There is *setState* and *replaceState*
    It seems that render reuses components, but if the component is between braces, they are instantiated on each render.
        Therefore: this way to introduce visibility is instantiating a component on each render: https://eddyerburgh.me/toggle-visibility-with-react
            It has performance implications.
            If there is a reference to the component it will not be freed and we have a memory leak
            The state of the component has to be reinitialized
        Note that if this happens at some point up in the tree containing this component we have the same problem.
        
    Steps:
    
        ☑ Make an asynchronous request returning data to be shown in the table component.
            ☑ From this stackoverflow answer (https://stackoverflow.com/a/31869669/10279433) I get that the component has to register a listener somewhere and be called later in order to update its state. Probably this is related with Redux, but I don't see any problem with this simplistic approach.
        ☑ Try to make the component generic
        ☑ Solve the fact that changing the tab erases the component
            This way to introduce visibility is instantiating a component on each render: https://eddyerburgh.me/toggle-visibility-with-react

    Questions:
    
        ☑ How do I create a hello world SPA? Do I create a HTML template and insert react controls? Do I create a root control and all the other react controls nested on it?
            Both options seem possible. I'll try to go for having a root React component.
        ☑ Does the tab component contain a panel that is changed everytime? it seems it does not.
        ☑ Can we make a REST GET query and populate the data accordingly (rows and columns)? We will not be able to populate the columns if the request contains no entity (could this be useful https://www.django-rest-framework.org/tutorial/7-schemas-and-client-libraries/?).
            We are setting the columns as props and updating the control with a callback
        ☑ Can we have only one component for the table (and have a specialization of it whenever we need something different)? Yes
        ☑ We are introducing listeners, pointers to our component. This means that the memory used by it will not be freed if the component is not necessary anymore. How are components instantiated and how long do they live? It seems that render reuses components, but if the component is between braces, they are instantiated on each render.
        ☐ How does conditional rendering (https://reactjs.org/docs/conditional-rendering.html) affects the child component lifecycle?
        ☐ How do I babelize the result?

# 6h: 

    Searching for component destroying I found the react oficial component lifecycle documentation (https://reactjs.org/docs/react-component.html) which contains a reference to a nice diagram (http://projects.wojtekmaj.pl/react-lifecycle-methods-diagram/).

    Steps:
        
        ☑ Try conditional rendering
        ☑ Try to replace the event management with a built in system (EventTarget)

    Questions:

        ☑ How do I create a hello world SPA? Do I create a HTML template and insert react controls? Do I create a root control and all the other react controls nested on it?
            Both options seem possible. I'll try to go for having a root React component.
        ☑ Does the tab component contain a panel that is changed everytime? it seems it does not.
        ☑ Can we make a REST GET query and populate the data accordingly (rows and columns)? We will not be able to populate the columns if the request contains no entity (could this be useful https://www.django-rest-framework.org/tutorial/7-schemas-and-client-libraries/?).
            We are setting the columns as props and updating the control with a callback
        ☑ Can we have only one component for the table (and have a specialization of it whenever we need something different)? Yes
        ☑ We are introducing listeners, pointers to our component. This means that the memory used by it will not be freed if the component is not necessary anymore. How are components instantiated and how long do they live? It seems that render reuses components, but if the component is between braces, they are instantiated on each render.
        ☑ How does conditional rendering (https://reactjs.org/docs/conditional-rendering.html) affects the child component lifecycle? In any case we cannot use it because the condition would be used inside the JSX code.
        ☐ How do I babelize the result?


# 8h: 

    I could not manage to free the memory of the child components between curly braces, so from now on I'll try not to use that syntax. In any case it is more performant.
    If you use create-react-app, you can customize everything by *ejecting*: https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#npm-run-eject

    Steps:

        ☑ Try to put the data in the components in different ways
            ☑ with a listener
                ☑ remove the association at component destruction and fix the memory leak
            ☑ is it possible to set it as a property in the root of the tree and pass it down the tree? sounds like a lot for big trees, so we do not do it.
            ☑ is it possible to set it as properties? I do nor care.
        ☑ Recover the previous implementation in order not to lose the contents of the table (or can we still find a solution with these short lived objects?)
        ☑ Package it for reuse.

    Questions:

        ☑ How do I create a hello world SPA? Do I create a HTML template and insert react controls? Do I create a root control and all the other react controls nested on it?
            Both options seem possible. I'll try to go for having a root React component.
        ☑ Does the tab component contain a panel that is changed everytime? it seems it does not.
        ☑ Can we make a REST GET query and populate the data accordingly (rows and columns)? We will not be able to populate the columns if the request contains no entity (could this be useful https://www.django-rest-framework.org/tutorial/7-schemas-and-client-libraries/?).
            We are setting the columns as props and updating the control with a callback
        ☑ Can we have only one component for the table (and have a specialization of it whenever we need something different)? Yes
        ☑ We are introducing listeners, pointers to our component. This means that the memory used by it will not be freed if the component is not necessary anymore. How are components instantiated and how long do they live? It seems that render reuses components, but if the component is between braces, they are instantiated on each render.
        ☑ How does conditional rendering (https://reactjs.org/docs/conditional-rendering.html) affects the child component lifecycle? In any case we cannot use it because the condition would be used inside the JSX code.
        ☑ How do I babelize the result? It is babelized, you can eject and edit the defaults.
