module namespace my = "http://example.org/ns/my";

declare function my:square($n as xs:integer)
  as xs:integer
{
  $n * $n
};
