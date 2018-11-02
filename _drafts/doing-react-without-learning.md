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


# h: 

    Steps:

        ☐ Try to put the data in the components in different ways
            ☐ with a listener
                ☐ remove the association at component destruction and fix the memory leak
            ☐ is it possible to set it as a property in the root of the tree and pass it down the tree? sounds like a lot for big trees.
            ☐ is it possible to set it as properties?
        ☐ Recover the previous implementation in order not to lose the contents of the table (or can we still find a solution with these short lived objects?)
        ☐ Package it for reuse.

    Questions:

# 4h: 

    Steps:

    Questions:

# 4h: 

    Steps:

    Questions:

# 4h: 

    Steps:

    Questions:

# 4h: 

    Steps:

    Questions:

# 4h: 

    Steps:

    Questions:

# 4h: 

    Steps:

    Questions:

# 4h: 

    Steps:

    Questions:

# 4h: 

    Steps:

    Questions:

# 4h: 

    Steps:

    Questions:
