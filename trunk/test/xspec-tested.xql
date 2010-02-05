(::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)
(:  File:       test/xspec-tested.xql                                       :)
(:  Author:     Jeni Tennsion                                               :)
(:  URI:        http://xspec.googlecode.com/                                :)
(:  Tags:                                                                   :)
(:    Copyright (c) 2010 Jeni Tennsion (see end of file.)                   :)
(: ------------------------------------------------------------------------ :)


module namespace my = "http://example.org/ns/my";

declare function my:square($n as xs:integer)
  as xs:integer
{
  $n * $n
};


(: ------------------------------------------------------------------------ :)
(:  DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.               :)
(:                                                                          :)
(:  Copyright (c) 2010 Jeni Tennsion                                        :)
(:                                                                          :)
(:  The contents of this file are subject to the MIT License (see the URI   :)
(:  http://www.opensource.org/licenses/mit-license.php for details).        :)
(:                                                                          :)
(:  Permission is hereby granted, free of charge, to any person obtaining   :)
(:  a copy of this software and associated documentation files (the         :)
(:  "Software"), to deal in the Software without restriction, including     :)
(:  without limitation the rights to use, copy, modify, merge, publish,     :)
(:  distribute, sublicense, and/or sell copies of the Software, and to      :)
(:  permit persons to whom the Software is furnished to do so, subject to   :)
(:  the following conditions:                                               :)
(:                                                                          :)
(:  The above copyright notice and this permission notice shall be          :)
(:  included in all copies or substantial portions of the Software.         :)
(:                                                                          :)
(:  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,         :)
(:  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF      :)
(:  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  :)
(:  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY    :)
(:  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,    :)
(:  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE       :)
(:  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                  :)
(: ------------------------------------------------------------------------ :)
