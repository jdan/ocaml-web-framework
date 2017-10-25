let rec tag name ?(attrs=[]) children =
  let rec string_of_attr_list = function
    | [] -> ""
    | (key, value) :: rest ->
      (Printf.sprintf " %s=\"%s\"" key value) ^
      (string_of_attr_list rest)
  in

  Printf.sprintf "<%s%s>%s</%s>"
    name
    (string_of_attr_list attrs)
    (String.concat "" children)
    name

let html = tag "html"
let head = tag "head"
let title = tag "title"
let style = tag "style"
let body = tag "body"
let div = tag "div"
let h1 = tag "h1"
let h2 = tag "h2"
let strong = tag "strong"
