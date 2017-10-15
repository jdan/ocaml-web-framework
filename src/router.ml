type params = (string * string) list

let match_pattern pattern url =
  let all_match_groups re str =
    let rec inner i =
      try
        let q = Str.matched_group i str in
        q :: inner (i + 1)
      with Invalid_argument _ -> [] in

    if Str.string_match re str 0 then
      Some (inner 1)
    else None in

  let regexp_of_pattern pattern =
    let token_re = Str.regexp ":[A-Za-z0-9_]+" in
    let tokens_to_groups = Str.global_replace token_re "\\([A-Za-z0-9_]+\\)" pattern in
    Str.regexp ("^" ^ tokens_to_groups ^ "$") in

  let params_in_pattern pattern =
    let without_colons = Str.global_replace (Str.regexp_string ":") "" pattern in
    all_match_groups (regexp_of_pattern pattern) without_colons in

  let rec zip a b = match (a, b) with
    | (a::at, b::bt) -> (a, b) :: zip at bt
    | _ -> [] in

  let re = regexp_of_pattern pattern in
  if Str.string_match re url 0 then
    let param_names = params_in_pattern pattern in
    let param_values = all_match_groups re url in
    match (param_names, param_values) with
    | (Some a, Some b) -> Some (zip a b)
    | _ -> None
  else
    None
