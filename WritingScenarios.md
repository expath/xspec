# Contents #



# Introduction #

The description of the behaviour of a stylesheet lives within an XSpec document, which should adhere to the [XSpec RELAX NG schema](http://code.google.com/p/xspec/source/browse/trunk/xspec.rnc). All elements are in the `http://www.jenitennison.com/xslt/xspec` namespace, which is bound to `x` in these examples.

The document element is a `<x:description>` element, whose `stylesheet` attribute holds a relative URI pointing to the stylesheet that the XSpec document describes. You can also specify:

  * a `version` attribute that gives the version of the stylesheet the XSpec document describes
  * a `xslt-version` attribute that gives the version of XSLT the stylesheet uses; if you don't specify it, this defaults to 2.0

The `<x:description>` element contains a number of `<x:scenario>` elements, each of which describes a particular scenario that's being tested. Each `<x:scenario>` element has a `label` attribute that describes the scenario in human language. For example:

```
<x:scenario label="when processing a para element">
  ...
</x:scenario>
```

Scenarios fall into three main types:

  * **[matching scenarios](#Matching_Scenarios.md)** describe the result of applying templates to a node in a particular mode (and with particular parameters)
  * **[function scenarios](#Function_Scenarios.md)** describe the results of calling a particular function with particular arguments
  * **[named scenarios](#Named_Scenarios.md)** describe the results of calling a particular named template with particular parameters

# Matching Scenarios #

Matching scenarios hold a `<x:context>` element that describes a node to apply templates to. The context can be supplied in two main ways:

  * you can point to a node in an existing document by giving the document URI in the `href` attribute and, if you want, selecting a particular node by putting a path in the `select` attribute
  * you can embed XML within the `<x:context>` element; the content becomes the context node, although you can also select a node within that XML using the `select` attribute

The first method is useful if you already have example XML documents that you want to use as the basis of your testing. For example:

```
<x:scenario label="when processing a para element">
  <x:context href="source/test.xml" select="/doc/body/p[1]" />
  ...
</x:scenario>
```

The second method is related to the concept of a [mock object](http://en.wikipedia.org/wiki/Mock_object): it is an example of some XML which you have created simply for testing purposes. The XML might not be legal; it only needs to have the attributes or content necessary for the particular behaviour that needs to be tested. For example:

```
<x:scenario label="when processing a para element">
  <x:context>
    <para>...</para>
  </x:context>
  ...
</x:scenario>
```

The `<x:context>` element can also have a `mode` attribute that supplies the mode to apply templates in.

# Function Scenarios #

Function scenarios hold a `<x:call>` element with a `function` attribute whose content is a qualified name that is the same as the qualified name of the function you want to call. The `<x:call>` element should hold a number of `<x:param>` elements, one for each of the arguments to the function.

The `<x:param>` elements can specify node values in the same way as the `<x:context>` element gets set (described above), or simply by giving a `select` attribute which holds an XPath that specifies the value. You can specify a `name` or `position` attribute for each of the `<x:param>` elements; if you don't, the order in which they're specified will determine the order in which they're given in the function call. For example:

```
<x:scenario label="when capitalising a string">
  <x:call function="eg:capital-case">
    <x:param select="'an example string'" />
    <x:param select="true()" />
  </x:call>
  ...
</x:scenario>
```

will result in the call `eg:capital-case('an example string', false())` as will:

```
<x:scenario label="when capitalising a string">
  <x:call function="eg:capital-case">
    <x:param select="true()" position="2" />
    <x:param select="'an example string'" position="1" />
  </x:call>
  ...
</x:scenario>
```

# Named Scenarios #

Named template scenarios are similar to function scenarios except that the `<x:call>` element takes a `template` attribute rather than a `function` attribute, and the `<x:param>` elements within it must have a `name` attribute that supplies the name of the parameter. These parameters can also have a `tunnel` attribute to indicate a tunnel parameter. For example:

```
<x:scenario label="when creating a table with two columns containing three values">
  <x:call template="createTable">
    <x:param name="nodes">
      <value>A</value>
      <value>B</value>
      <value>C</value>
    </x:param>
    <x:param name="cols" select="2" />
  </x:call>
  ...
</x:scenario>
```

In fact, you can use `<x:param>` in the same way within the `<x:context>` element in matching scenarios.

# Expectations #

Each scenario can have one or more "expectations": things that should be true of the result of the function or template invocation described by the scenario. Each expectation is specified with an `<x:expect>` element. The `label` attribute on the `<x:expect>` element gives a human-readable description of the expectation.

There are two main kinds of expectations:

  * a value that the result should match, which may be
    * an atomic value
    * an XML snippet
  * an arbitrary XPath test that should be true of the result

To specify an atomic value, use the `select` attribute on the `<x:expect>` element. For example:

```
<x:scenario label="when capitalising a string">
  <x:call function="eg:capital-case">
    <x:param select="'an example string'" />
    <x:param select="true()" />
  </x:call>
  <x:expect label="it should capitalise every word in the string" select="'An Example String'" />
</x:scenario>
```

To specify some XML, put it within the `<x:expect>` element. For example:

```
<x:scenario label="when processing a para element">
  <x:context>
    <para>...</para>
  </x:context>
  <x:expect label="it should produce a p element">
    <p>...</p>
  </x:expect>
</x:scenario>
```

One thing to note here is that when comparing the actual result with the expected result, three dots in an element or attribute value within the expected XML means that the values aren't compared. If the actual result is:

```
  <p>A sample para</p>
```

and the expected result is given as:

```
  <p>...</p>
```

then these match. If the expected result is:

```
  <p>Some other para</p>
```

then they don't.

To specify an arbitrary XPath test, use the `test` attribute on `<x:expect>`. For example:

```
<x:scenario label="when creating a table with two columns containing three values">
  <x:call template="createTable">
    <x:param name="nodes">
      <value>A</value>
      <value>B</value>
      <value>C</value>
    </x:param>
    <x:param name="cols" select="2" />
  </x:call>
  <x:expect label="the resulting table should have two columns"
    test="count(/table/colspec/col) = 2" />
</x:scenario>
```

Within the XPath expression, you can use the variable `$x:result` to access the result of the test (i.e. the result of calling the function or the template, or of applying the template rule).  In addition, if the result is a sequence of nodes, it is wrapped in a document node and this document is set as the context node of the expression.

You can also combine the `test` attribute with the content of the `<x:expect>` element if you want to just test a portion of the result. For example:

```
<x:scenario label="when creating a table with two columns containing three values">
  <x:call template="createTable">
    <x:param name="nodes">
      <value>A</value>
      <value>B</value>
      <value>C</value>
    </x:param>
    <x:param name="cols" select="2" />
  </x:call>
  <x:expect label="the resulting table should have two columns"
    test="count(/table/colspec/col) = 2" />
  <x:expect label="the first row should contain the first two values"
    test="/table/tbody/tr[1]">
    <tr>
      <td>A</td><td>B</td>
    </tr>
  </x:expect>
</x:scenario>
```

# Nesting Scenarios #

You can nest scenarios inside each other. The nested scenarios inherit the context or call from its ancestor scenarios. All the scenarios in a particular tree have to be of the same type (matching, function or named). Usually only the lowest level of the scenarios will contain any expectations. Here's an example:

```
<x:scenario label="when creating a table">
  <x:call template="createTable" />
  <x:scenario label="holding three values">
    <x:call>
      <x:param name="nodes">
        <value>A</value>
        <value>B</value>
        <value>C</value>
      </x:param>
    </x:call>
    <x:scenario label="in two columns">
      <x:call>
        <x:param name="cols" select="2" />
      </x:call>
      <x:expect label="the resulting table should have two columns"
        test="count(/table/colspec/col) = 2" />
      <x:expect label="the first row should contain the first two values"
        test="/table/tbody/tr[1]">
        <tr>
          <td>A</td><td>B</td>
        </tr>
      </x:expect>
    </x:scenario>
    ... other scenarios around creating tables with three values (with different numbers of columns) ...
  </x:scenario>
  ... other scenarios around creating tables ...
</x:scenario>
```

When you create scenarios like this, the labels of the nested scenarios are concatenated to create the label for the scenario. In the above example, the third scenario has the label "when creating a table holding three values in two columns".

# Focusing Your Efforts #

XSpec descriptions can get quite large, which can mean that running the tests takes some time. There are three ways of dealing with this.

First, you can import other XSpec description documents into your main one using `<x:import>`. The `href` attribute holds the location of the imported document. All the scenarios from the referenced document are imported into this one, and will be run when you execute it. For example:

```
<x:import href="other_xspec.xml" />
```

It helps if the imported XSpec description documents can stand alone; this enables you to perform a subset of the tests. To work effectively, you'll want the imported XSpec description documents to cover the same stylesheet as the main one, or a stylesheet module that's included or imported into that stylesheet.

Second, you can mark any scenario or expectation as "pending" by wrapping them within a `<x:pending>` element or adding a `pending` attribute to the `<x:scenario>` element. When the tests are run, any pending scenarios or expectations aren't tested (though they still appear, greyed out, in the test report). The `<x:pending>` element can have a `label` attribute to describe why the particular description is pending; for example it might hold "TODO". If you use the `pending` attribute, its value should give the reason the tests are pending. For example:

```
<x:pending label="no support for block elements yet">
  <x:scenario label="when processing a para element">
    <x:context>
      <para>...</para>
    </x:context>
    <x:expect label="it should produce a p element">
      <p>...</p>
    </x:expect>
  </x:scenario>
</x:pending>
```

or:

```
<x:scenario pending="no support for block elements yet" label="when processing a para element">
  <x:context>
    <para>...</para>
  </x:context>
  <x:expect label="it should produce a p element">
    <p>...</p>
  </x:expect>
</x:scenario>
```

Third, you can mark any scenario as having the current "focus" by adding a `focus` attribute to a `<x:scenario>` element. Effectively, this marks every _other_ scenario as "pending", with the label given as the value of the `focus` attribute. For example:

```
<x:scenario focus="getting capitalisation working" label="when capitalising a string">
  <x:call function="eg:capital-case">
    <x:param select="'an example string'" />
    <x:param select="true()" />
  </x:call>
  <x:expect label="it should capitalise every word in the string" select="'An Example String'" />
</x:scenario>
```

> _Using focus is a good way of working through one particular scenario, but once your code is working with that
> scenario, you should always test all the others again, just in case you've broken something else._

# Global Parameters #

You can put `<x:param>` elements at the top level of the XSpec description document (as a child of the `<x:description>` element). These effectively override any global parameters or variables that you have declared in your stylesheet. They are set in just the same way as setting parameters when testing [named templates](#Named_Scenarios.md) or [functions](#Function_Scenarios.md).

> _With the current XSLT-based implementation, it isn't possible to have different scenarios use different values
> for global parameters. Hopefully that will come with an XProc-based implementation. Testing is made easier if
> you declare local parameters on any templates or functions that use global parameters; these can default to
> the value of the global parameter, but be set explicitly when testing. For example, if `$tableClass` is a global
> parameter, you might do_

```
    <xsl:template name="createTable">
      <xsl:param name="nodes" as="node()+" required="yes" />
      <xsl:param name="cols" as="xs:integer" required="yes" />
      <xsl:param name="tableClass" as="xs:string" select="$tableClass" />
      ...
    </xsl:template>
```

> _to enable the full testing of the `createTable` template._