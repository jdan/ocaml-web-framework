## ocaml-web-framework

This is an HTTP server and framework written from scratch in OCaml. It uses UNIX sockets and builds up some abstractions to resemble [the Sinatra framework](http://www.sinatrarb.com/).

Thanks to [Gary Bernhardt](http://twitter.com/garybernhardt) for his [HTTP Server from Scratch](https://www.destroyallsoftware.com/screencasts/catalog/http-server-from-scratch) screencast which inspired this project.

### Build etc

```sh
$ make
$ make test
```

### Example

```ocaml
open Framework

let () =
  create_server ()
  |> get "/" (fun _ -> "This is the index page.")
  |> get "/:name" (fun params ->
      (Printf.sprintf "Hello, %s!" (List.assoc "name" params)))
  |> listen 1337
```

