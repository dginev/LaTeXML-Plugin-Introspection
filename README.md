LaTeXML-Plugin-Introspection
============================

LaTeXML introspection for TeX package dependencies and command sequence dictionaries

To generate the full reports (in the default dictionary.json and dependencies.json files) run:
```
perl generate_reports.pl
```

To generate the reports for any subset of packages, simply supply them as arguments:
```
perl generate_reports.pl article.cls graphicx.sty tikz.sty
```

If this proves useful, and once the method is refined to be as efficient as possible, it might be advantageous to integrate this functionality in the [LaTeXML web service](https://github.com/dginev/LaTeXML-Plugin-ltxmojo).