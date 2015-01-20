css-inspector
=============

ウェブページ上のスタイルシートを調査するライブラリ。

A Node.js library for inspection stylesheets in a web page.

Usage
-----

ウェブページを調査するには、`#inspect` 関数にページの URL を指定します。

To inspect a web page, pass the URL to `#inspect`.

```javascript
var PageInspector = require('drcss-inspector').inspectors.PageInspector;
var inspector = new PageInspector

inspector.inspect('http://example.com/', function (err, inspectResult) {
  // finished inspection!
});
```

### `inspectResult`

TODO

```javascript
{ html: '<!doctype html>...', 
  cssCodes: 
   [ { index: 0,
       element: [Object],
       css: '\n    body {\n        background-color: #f0f0f2;...' ],
  declarations: 
   [ { ruleStack: [Object],
       selectors: [Object],
       property: 'background-color',
       value: '#f0f0f2',
       line: 3,
       col: 9,
       href: '',
       baseUrl: 'http://example.com/',
       text: 'background-color:#f0f0f2' },
     { ruleStack: [Object],
       selectors: [Object],
       property: 'padding',
       value: '0',
       line: 5,
       col: 9,
       href: '',
       baseUrl: 'http://example.com/',
       text: 'padding:0' }, 
       ...
   ] }
```
