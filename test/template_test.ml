open Template

let go () =
  assert ("<div>Hello, world!</div>" = div ["Hello, world!"]);
  assert ("<div>Hello, <strong>world!</strong></div>" =
          div [
            "Hello, " ;
            strong ["world!"] ;
          ]);

  assert ("<h1 class=\"huge\">Title</h1>" =
          h1 ~attrs:[("class", "huge")] ["Title"]);
