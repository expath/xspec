Currently, to run the tests, the [XSpec description document](WritingScenarios.md) is transformed into an XSLT stylesheet which imports the stylesheet being tested. Running _this_ stylesheet results in an XML document that holds the results, which is then transformed into an HTML report. The two stylesheets involved in this process are:

  * [generate-xspec-tests.xsl](http://code.google.com/p/xspec/source/browse/trunk/generate-xspec-tests.xsl), to transform the XSpec document into XSLT
  * [format-xspec-report.xsl](http://code.google.com/p/xspec/source/browse/trunk/format-xspec-report.xsl), to transform the XML report into HTML

Two scripts are provided that will perform this pipeline for you:

  * [xspec.bat](http://code.google.com/p/xspec/source/browse/trunk/xspec.bat), a Windows batch script.
  * [xspec.sh](http://code.google.com/p/xspec/source/browse/trunk/xspec.sh), a bash script for Mac OS X (might work on linux, but untested).

Note that you will have to edit each script to match the location of Saxon on your system.

To run the batch/bash scripts, use the command line:

```
> xspec filename
```

Two alternative scripts are also provided:

  * [build.xml](http://code.google.com/p/xspec/source/browse/trunk/build.xml), an Ant build. You will have to edit the script to point to location of Saxon on your system. To run, use the command line:

```
    > ant -Dxspec.xml=filename
```

> Also see RunningWithAnt.

  * [xspec.xpl](http://code.google.com/p/xspec/source/browse/trunk/xspec.xpl), an XProc pipeline (note that it doesn't indent the XML output correctly). To run, use the command line:

```
   > java com.xmlcalabash.drivers.Main -i source=filename xspec.xpl
```

You can also [integrate XSpec into Oxygen](http://www.wordsinboxes.com/2008/12/getting-started-with-xspec.html).

If you develop more scripts, please share them.