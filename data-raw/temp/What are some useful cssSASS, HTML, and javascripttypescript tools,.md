[TOC]





# What are some useful css/SASS, HTML, and javascript/typescript tools,...

Exported on 05/08/2024 at 17:31:12 [from Perplexity.ai](https://www.perplexity.ai/search/what-are-some-useful-css-sass-_CKp0DczTbuUkiLKwnb6rw) - with [SaveMyChatbot](https://save.hugocollin.com)

## User

What are some useful css/SASS, HTML, and javascript/typescript tools, libraries, or code snippets that are not widely known to use with R shiny

## Pro answer
Integrating CSS/SASS, HTML, and JavaScript/TypeScript into R Shiny applications can significantly enhance the user interface and interactivity of your apps. Below are some useful tools, libraries, and code snippets that are not widely known but can be very effective when used with R Shiny.

CSS/SASS Tools and Libraries
----------------------------

**1\. Sass Integration**
------------------------

Sass is a powerful CSS preprocessor that allows you to use variables, nested rules, and functions, which can make your CSS more maintainable. In Shiny, you can compile Sass code into CSS before launching your app.

```r
library(sass)

sass(
  list(
    color = "pink",
    size = "30px",
    ".awesome-link {
      color: $color;
      font-size: $size;
      &:hover {
        color: green;
      }
    }"
  ),
  output = "www/main.min.css",
  options = sass_options(
    output_style = "compressed",
    source_map_embed = TRUE
  )
)
```

This code compiles Sass into a minified CSS file, which can then be included in your Shiny app [1](https://unleash-shiny.rinterface.com/beautify-sass).

**2\. `{bs4Dash}` Customization**
---------------------------------

`{bs4Dash}` is a Bootstrap 4 dashboard template that uses Sass for customization. You can modify theme colors by changing the variables in the `_variables.scss` partial and recompiling the Sass code.

```text
$blue: #d8bc66 !default;
$olive: #fcec0c !default;
$lime: #978d01 !default;
$orange: #58482c !default;
```

Recompile the Sass code to apply these custom colors [1](https://unleash-shiny.rinterface.com/beautify-sass).

HTML Tools and Libraries
------------------------

**1\. `htmltools`**
-------------------

`htmltools` is an R package that makes it easy to create, manipulate, and write HTML from R. It allows you to generate custom HTML, including JavaScript and CSS.

```r
library(htmltools)
library(plotly)

browsable(tagList(
  plot_ly(diamonds, x = ~carat, height = 200),
  plot_ly(diamonds, x = ~price, height = 200)
))
```

This example shows how to arrange multiple `htmlwidgets` into a single static HTML webpage [3](https://rstudio.github.io/htmltools/index.html).

**2\. Embedding HTML with JavaScript**
--------------------------------------

You can embed HTML that includes JavaScript directly into your Shiny app using `tags$div(HTML())`.

```r
ui <- fluidPage(
  tags$div(HTML("
    <a class='weatherwidget-io' href='https://forecast7.com/en/40d71n74d01/new-york/' data-label_1='New York' data-label_2='Weather' data-font='Fira Sans' data-days='3' data-theme='weather_one'>My Weather</a>
    <script>
      !function(d,s,id){var js,fjs=d.getElementsByTagName(s);if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src='https://weatherwidget.io/js/widget.min.js';fjs.parentNode.insertBefore(js,fjs);}}(document,'script','weatherwidget-io-js');
    </script>
  "))
)
```

This snippet embeds a weather widget into your Shiny app [4](https://stackoverflow.com/questions/68219365/displaying-html-with-javascript-in-r-shiny).

JavaScript/TypeScript Tools and Libraries
-----------------------------------------

**1\. `shinyjs`**
-----------------

`shinyjs` allows you to easily call JavaScript functions from R without writing JavaScript code. It provides functions to hide/show elements, disable/enable inputs, and more.

```r
library(shiny)
library(shinyjs)

ui <- fluidPage(
  useShinyjs(),
  actionButton("btn", "Click me"),
  textInput("text", "Text input")
)

server <- function(input, output) {
  observeEvent(input$btn, {
    toggle("text")
  })
}

shinyApp(ui, server)
```

This example toggles the visibility of a text input when a button is clicked [7](https://engineering-shiny.org/using-javascript.html).

**2\. Integrating Third-Party JavaScript Libraries**
----------------------------------------------------

You can integrate third-party JavaScript libraries into Shiny apps. For example, using Highcharts for advanced charting.

```r
library(shiny)
library(highcharter)

ui <- fluidPage(
  highchartOutput("chart")
)

server <- function(input, output) {
  output$chart <- renderHighchart({
    hchart(mtcars, "scatter", hcaes(x = mpg, y = wt))
  })
}

shinyApp(ui, server)
```

This example uses the `highcharter` package to render a scatter plot [6](https://github.com/wch/shiny-jsdemo).

**3\. Custom JavaScript Handlers**
----------------------------------

You can define custom JavaScript handlers to communicate between R and JavaScript.

```js
$(document).ready(function() {
  Shiny.addCustomMessageHandler('customMessage', function(message) {
    alert("Received: " + message.text);
  });
});
```

In your server-side R code, you can send messages to this handler.

```r
session$sendCustomMessage("customMessage", list(text = "Hello, world!"))
```

This setup allows for custom interactivity between R and JavaScript [7](https://engineering-shiny.org/using-javascript.html). These tools and snippets can help you create more dynamic and interactive Shiny applications by leveraging the power of CSS/SASS, HTML, and JavaScript/TypeScript.

---
**Sources:**
- [(1) 7 Tidy your CSS with Sass - Outstanding User Interfaces with Shiny](https://unleash-shiny.rinterface.com/beautify-sass)
- [(2) nanxstats/awesome-shiny-extensions - GitHub](https://github.com/nanxstats/awesome-shiny-extensions)
- [(3) Tools for HTML • htmltools - rstudio.github.io](https://rstudio.github.io/htmltools/index.html)
- [(4) Displaying HTML with JavaScript in R Shiny: - Stack Overflow](https://stackoverflow.com/questions/68219365/displaying-html-with-javascript-in-r-shiny)
- [(5) Chapter 10 JavaScript for Shiny](https://unleash-shiny.rinterface.com/survival-kit-javascript)
- [(6) Demo of Shiny integration with third-party Javascript libraries - GitHub](https://github.com/wch/shiny-jsdemo)
- [(7) 17 Using JavaScript - Engineering Production-Grade Shiny Apps](https://engineering-shiny.org/using-javascript.html)


## User
What are some unique ways to customize Shiny UI with Bootstrap

## Pro answer
Customizing the UI of a Shiny application with Bootstrap can significantly enhance its appearance and usability. Here are some unique ways to achieve this using various tools and techniques:

**1\. Using `bslib` for Theming**
---------------------------------

**Bootswatch Themes**
---------------------

The `bslib` package allows you to easily apply and customize Bootstrap themes. You can use Bootswatch themes to quickly change the look of your app.

```r
library(shiny)
library(bslib)

ui <- fluidPage(
  theme = bs_theme(bootswatch = "darkly"),
  sidebarLayout(
    sidebarPanel(
      textInput("txt", "Text input:", "text here"),
      sliderInput("slider", "Slider input:", 1, 100, 30)
    ),
    mainPanel(
      h1("Theme: darkly"),
      h2("Header 2"),
      p("Some text")
    )
  )
)

server <- function(input, output) {}

shinyApp(ui, server)
```

**Custom Themes**
-----------------

You can also create custom themes by specifying background colors, foreground colors, and fonts.

```r
ui <- fluidPage(
  theme = bs_theme(
    bg = "#0b3d91",
    fg = "white",
    primary = "#E69F00",
    secondary = "#0072B2",
    base_font = font_google("Inter"),
    code_font = font_google("JetBrains Mono")
  ),
  sidebarLayout(
    sidebarPanel(
      textInput("txt", "Text input:", "text here"),
      sliderInput("slider", "Slider input:", 1, 100, 30)
    ),
    mainPanel(
      h1("Custom Theme"),
      h2("Header 2"),
      p("Some text")
    )
  )
)
```

**2\. Custom CSS**
------------------

**Inline CSS**
--------------

For small customizations, you can add inline CSS directly in the UI components.

```r
ui <- fluidPage(
  tags$style(HTML("
    .custom-header { color: white; background: #2A2A2A !important; }
  ")),
  div(class = "custom-header", "Custom Header"),
  p("Some text")
)
```

**External CSS File**
---------------------

For larger customizations, you can include an external CSS file.

```r
ui <- fluidPage(
  includeCSS("www/custom.css"),
  div(class = "custom-header", "Custom Header"),
  p("Some text")
)
```

**3\. Layout Customization**
----------------------------

**Grid Layouts**
----------------

Using `bslib`, you can create complex layouts with grid systems.

```r
ui <- fluidPage(
  page_fillable(
    layout_columns(
      card(card_header("Card 1")),
      card(card_header("Card 2")),
      card(card_header("Card 3"))
    )
  )
)
```

**Responsive Layouts**
----------------------

Bootstrap's grid system supports responsive layouts, allowing your app to adapt to different screen sizes.

```r
ui <- fluidPage(
  page_fillable(
    layout_columns(
      card(card_header("Card 1"), "Content 1"),
      card(card_header("Card 2"), "Content 2"),
      card(card_header("Card 3"), "Content 3"),
      col_widths = breakpoints(
        sm = c(4, 4, 4),
        md = c(3, 3, 6),
        lg = c(-2, 8, -2)
      )
    )
  )
)
```

**4\. Utility Classes**
-----------------------

Bootstrap utility classes can be used to quickly style elements without writing custom CSS.

```r
ui <- fluidPage(
  div(class = "bg-primary text-white p-3", "Primary Background"),
  p(class = "lead", "Lead Text")
)
```

**5\. Theme Selector for Development**
--------------------------------------

During development, you can use a theme selector to quickly switch between themes.

```r
ui <- fluidPage(
  shinythemes::themeSelector(),
  sidebarLayout(
    sidebarPanel(
      textInput("txt", "Text input:", "text here"),
      sliderInput("slider", "Slider input:", 1, 100, 30)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Tab 1"),
        tabPanel("Tab 2")
      )
    )
  )
)
```

These methods provide a range of options for customizing the look and feel of your Shiny applications, leveraging the power of Bootstrap and the flexibility of custom CSS.

---
**Sources:**
- [(1) Theming - Shiny - Posit](https://shiny.posit.co/r/getstarted/build-an-app/customizing-ui/theming.html)
- [(2) Chapter 6 Layout, themes, HTML | Mastering Shiny](https://mastering-shiny.org/action-layout.html)
- [(3) Customizing UI - Shiny for Python - Posit](https://shiny.posit.co/py/docs/ui-customize.html)
- [(4) Application layout guide - Shiny - Posit](https://shiny.posit.co/r/articles/build/layout-guide/)
- [(5) Advanced Customization: The bslib and thematic packages](https://tilburgsciencehub.com/topics/visualization/data-visualization/dashboarding/advanced-ui-packages/)
- [(6) R Shiny bslib - How to Work With Bootstrap Themes in Shiny](https://www.appsilon.com/post/r-shiny-bslib)
- [(7) Shiny Themes - rstudio.github.io](https://rstudio.github.io/shinythemes/)


## User
What are some advanced CSS techniques to enhance Shiny UI with Bootstrap

## Pro answer
Enhancing the UI of a Shiny application with advanced CSS techniques and Bootstrap can significantly improve its aesthetics and usability. Here are some advanced techniques to achieve this:

**1\. Custom Themes with `bslib`**
----------------------------------

**Bootswatch Themes**
---------------------

Using the `bslib` package, you can easily apply and customize Bootswatch themes to quickly change the look and feel of your app.

```r
library(shiny)
library(bslib)

ui <- fluidPage(
  theme = bs_theme(bootswatch = "darkly"),
  sidebarLayout(
    sidebarPanel(
      textInput("txt", "Text input:", "text here"),
      sliderInput("slider", "Slider input:", 1, 100, 30)
    ),
    mainPanel(
      h1("Theme: darkly"),
      h2("Header 2"),
      p("Some text")
    )
  )
)

server <- function(input, output) {}

shinyApp(ui, server)
```

**Custom Themes**
-----------------

Create custom themes by specifying background colors, foreground colors, and fonts.

```r
ui <- fluidPage(
  theme = bs_theme(
    bg = "#0b3d91",
    fg = "white",
    primary = "#E69F00",
    secondary = "#0072B2",
    base_font = font_google("Inter"),
    code_font = font_google("JetBrains Mono")
  ),
  sidebarLayout(
    sidebarPanel(
      textInput("txt", "Text input:", "text here"),
      sliderInput("slider", "Slider input:", 1, 100, 30)
    ),
    mainPanel(
      h1("Custom Theme"),
      h2("Header 2"),
      p("Some text")
    )
  )
)
```

**2\. Custom CSS Techniques**
-----------------------------

**Inline CSS**
--------------

For quick and small customizations, you can add inline CSS directly in the UI components.

```r
ui <- fluidPage(
  tags$style(HTML("
    .custom-header { color: white; background: #2A2A2A !important; }
  ")),
  div(class = "custom-header", "Custom Header"),
  p("Some text")
)
```

**External CSS File**
---------------------

For larger customizations, include an external CSS file.

```r
ui <- fluidPage(
  includeCSS("www/custom.css"),
  div(class = "custom-header", "Custom Header"),
  p("Some text")
)
```

**CSS Grid Layouts**
--------------------

Utilize CSS Grid for complex layouts.

```r
ui <- fluidPage(
  tags$style(HTML("
    .grid-container {
      display: grid;
      grid-template-columns: auto auto auto;
      gap: 10px;
    }
    .grid-item {
      background-color: rgba(255, 255, 255, 0.8);
      border: 1px solid rgba(0, 0, 0, 0.8);
      padding: 20px;
      font-size: 30px;
      text-align: center;
    }
  ")),
  div(class = "grid-container",
      div(class = "grid-item", "1"),
      div(class = "grid-item", "2"),
      div(class = "grid-item", "3"),
      div(class = "grid-item", "4"),
      div(class = "grid-item", "5"),
      div(class = "grid-item", "6")
  )
)
```

**3\. Advanced Bootstrap Features**
-----------------------------------

**Utility Classes**
-------------------

Bootstrap utility classes can be used to quickly style elements without writing custom CSS.

```r
ui <- fluidPage(
  div(class = "bg-primary text-white p-3", "Primary Background"),
  p(class = "lead", "Lead Text")
)
```

**Responsive Layouts**
----------------------

Bootstrap's grid system supports responsive layouts, allowing your app to adapt to different screen sizes.

```r
ui <- fluidPage(
  fluidRow(
    column(width = 4, div(class = "bg-primary text-white p-3", "Column 1")),
    column(width = 4, div(class = "bg-secondary text-white p-3", "Column 2")),
    column(width = 4, div(class = "bg-success text-white p-3", "Column 3"))
  )
)
```

**4\. Using Sass for Advanced Styling**
---------------------------------------

**Sass Integration**
--------------------

Sass allows for more advanced styling capabilities such as variables, nested rules, and functions.

```r
library(sass)

sass(
  list(
    color = "pink",
    size = "30px",
    ".awesome-link {
      color: $color;
      font-size: $size;
      &:hover {
        color: green;
      }
    }"
  ),
  output = "www/main.min.css",
  options = sass_options(
    output_style = "compressed",
    source_map_embed = TRUE
  )
)
```

**Customizing Bootstrap Variables**
-----------------------------------

You can customize Bootstrap variables using Sass for a more tailored design.

```text
$primary: #ff6347;
$secondary: #6c757d;
$font-family-base: 'Roboto', sans-serif;

@import "bootstrap";
```

**5\. Practical UI Design Tips**
--------------------------------

**Color Scheme and Typography**
-------------------------------

Select a consistent color scheme and typography to improve the visual appeal and readability of your app.

```r
ui <- fluidPage(
  tags$style(HTML("
    body {
      background-color: #f0f0f0;
      color: #333;
      font-family: 'Open Sans', sans-serif;
    }
    h1, h2, h3 {
      color: #007BFF;
    }
  ")),
  h1("Custom Typography and Colors"),
  p("This is a paragraph with custom styles.")
)
```

**Minimize Cognitive Load**
---------------------------

Reduce cognitive load by creating a clear visual hierarchy and minimizing the number of elements on the screen.

```r
ui <- fluidPage(
  tags$style(HTML("
    .main-header {
      font-size: 2em;
      margin-bottom: 10px;
    }
    .sub-header {
      font-size: 1.5em;
      margin-bottom: 5px;
    }
  ")),
  div(class = "main-header", "Main Header"),
  div(class = "sub-header", "Sub Header"),
  p("Content goes here.")
)
```

These advanced CSS techniques, combined with Bootstrap's powerful features, can significantly enhance the UI of your Shiny applications, making them more visually appealing and user-friendly.

---
**Sources:**
- [(1) Chapter 6 CSS for Shiny](https://unleash-shiny.rinterface.com/beautify-css)
- [(2) daattali/advanced-shiny: Shiny tips & tricks for improving your apps ...](https://github.com/daattali/advanced-shiny)
- [(3) Using custom CSS in your app - Shiny - Posit](https://shiny.posit.co/r/articles/build/css/)
- (4) Styling Shiny apps with Sass and Bootstrap 4 | Posit (2020) - YouTube
- [(5) How to Make Your Shiny App Beautiful - Appsilon](https://www.appsilon.com/post/how-to-make-your-shiny-app-beautiful)


## User
How can I create custom Bootstrap components for Shiny apps

## Pro answer
Creating custom Bootstrap components for Shiny apps involves a combination of HTML, CSS, and JavaScript, along with R functions to integrate these components into the Shiny framework. Here are the key steps and best practices to achieve this:

**1\. Design the Component**
----------------------------

**HTML Markup**
---------------

Start by designing the HTML structure of your component. This involves creating the necessary HTML tags and attributes.

```xml
<div class="custom-component">
  <input type="text" class="custom-input" id="customInput">
  <button class="custom-button" onclick="handleClick()">Click Me</button>
</div>
```

**CSS Styling**
---------------

Style your component using CSS or Sass to ensure it fits well within your Shiny app's theme.

```text
.custom-component {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 10px;
  background-color: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 5px;
}

.custom-input {
  margin-bottom: 10px;
  padding: 5px;
  border: 1px solid #ced4da;
  border-radius: 4px;
}

.custom-button {
  padding: 5px 10px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.custom-button:hover {
  background-color: #0056b3;
}
```

**JavaScript Behavior**
-----------------------

Add JavaScript to handle interactions and behaviors.

```javascript
function handleClick() {
  var inputValue = document.getElementById('customInput').value;
  alert('Input value: ' + inputValue);
}
```

**2\. Integrate with Shiny**
----------------------------

**Create an R Function**
------------------------

Write an R function to generate the HTML markup for your component. Use `htmltools` to create the HTML tags.

```r
library(htmltools)

custom_component <- function(inputId) {
  div(class = "custom-component",
      tags$input(type = "text", class = "custom-input", id = inputId),
      tags$button(class = "custom-button", "Click Me", onclick = "handleClick()")
  )
}
```

**Include CSS and JavaScript**
------------------------------

Ensure your CSS and JavaScript are included in the Shiny app. You can use `tags$head` to include external files.

```r
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
    tags$script(src = "custom.js")
  ),
  custom_component("customInput")
)

server <- function(input, output) {}

shinyApp(ui, server)
```

**3\. Write Input Binding**
---------------------------

To make the custom component interact with Shiny, you need to write an input binding in JavaScript.

```javascript
var customInputBinding = new Shiny.InputBinding();

$.extend(customInputBinding, {
  find: function(scope) {
    return $(scope).find(".custom-input");
  },
  getValue: function(el) {
    return $(el).val();
  },
  setValue: function(el, value) {
    $(el).val(value);
  },
  subscribe: function(el, callback) {
    $(el).on("input.customInputBinding", function(e) {
      callback();
    });
  },
  unsubscribe: function(el) {
    $(el).off(".customInputBinding");
  }
});

Shiny.inputBindings.register(customInputBinding, 'shiny.customInput');
```

**4\. Use `bslib` for Theming**
-------------------------------

To ensure your custom component fits seamlessly with Bootstrap themes, use the `bslib` package.

**Create a Themeable Component**
--------------------------------

Define custom Sass rules and integrate them with `bs_theme()`.

```r
library(bslib)

person <- function(name, title, company) {
  div(
    class = "person",
    h3(class = "name", name),
    div(class = "title", title),
    div(class = "company", company)
  )
}

ui <- fluidPage(
  theme = bs_theme(bg = "#002B36", fg = "#EEE8D5") %>%
    bs_add_rules(sass::sass_file("person.scss")),
  person("Andrew Carnegie", "Owner", "Carnegie Steel Company"),
  person("John D. Rockefeller", "Chairman", "Standard Oil")
)

server <- function(input, output) {}

shinyApp(ui, server)
```

**5\. Structuring Your Project**
--------------------------------

**Organize Your Files**
-----------------------

Structure your project to keep styles, scripts, and components organized.

```text
project/
│ app.R
└─── www/
│   └─── custom.css
│   └─── custom.js
└─── R/
│   └─── custom_component.R
└─── styles/
│   └─── person.scss
```

**6\. Practical Use Cases**
---------------------------

**Custom Input Widgets**
------------------------

Create custom input widgets that can be reused across multiple Shiny apps.

```r
custom_text_input <- function(inputId, label) {
  div(class = "form-group shiny-input-container",
      tags$label(label, `for` = inputId),
      tags$input(id = inputId, type = "text", class = "form-control")
  )
}

ui <- fluidPage(
  custom_text_input("customText", "Custom Text Input"),
  textOutput("textValue")
)

server <- function(input, output) {
  output$textValue <- renderText({
    input$customText
  })
}

shinyApp(ui, server)
```

By following these steps and best practices, you can create custom Bootstrap components for Shiny apps that are both functional and visually appealing.

---
**Sources:**
- [(1) Build custom input objects - Shiny - Posit](https://shiny.posit.co/r/articles/build/building-inputs/)
- [(2) R Shiny bslib - How to Work With Bootstrap Themes in Shiny](https://www.appsilon.com/post/r-shiny-bslib)
- [(3) Announcing new R Shiny UI components - Posit](https://shiny.posit.co/blog/posts/announcing-new-r-shiny-ui-components/)
- [(4) Custom components • bslib - rstudio.github.io](https://rstudio.github.io/bslib/articles/custom-components/index.html)
- [(5) No Framework, No Problem! Structuring your project folder and ...](https://rviews.rstudio.com/2020/01/13/no-framework-no-problem-structuring-your-project-folder-and-creating-custom-shiny-components/)

