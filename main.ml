open Framework
open Template

let () =
  create_server ()
  |> get "/" (fun req ->
      html [
        head [title ["Home"]] ;
        body [
          h1 ["This is the index page"]
        ] ;
      ]
      |> respond)
  |> get "/:name" (fun req ->
      html [
        head [title [param req "name"]] ;
        body [
          h2
            ~attrs:[("style", "background:#222;color:papayawhip;")]
            [Printf.sprintf "Hello, %s!" (param req "name")]
        ] ;
      ]
      |> respond)
  |> listen 8080
