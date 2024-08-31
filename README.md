# ZTWIG
a small attempt to implement the twig template engine in the zig language.
not supported if/for and other features)0))0

### Usage:

```zig
var t = try template.loadFromFile("test/index.html");
const result = try t.render(.{.lang = "ru" });
```
