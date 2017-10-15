let go () =
  assert (Router.match_pattern "/" "/" = Some []);
  assert (Router.match_pattern "/" "/hello" = None);

  assert (Router.match_pattern "/:name" "/jordan" = Some [("name", "jordan")]);
  assert (Router.match_pattern "/:name" "/jordan/" = None);
  assert (Router.match_pattern "/users/:id" "/users/1" = Some [("id", "1")]);
  assert (Router.match_pattern "/users/" "/users/1" = None);

  assert
    (Router.match_pattern
       "/users/:uid/posts/:pid/comments"
       "/users/17/posts/28/comments"
     = Some [("uid", "17"); ("pid", "28")]);

  assert
    (Router.match_pattern
       "/users/:uid/posts/:pid/comments"
       "/users/17/posts/28"
     = None)
