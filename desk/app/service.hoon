/-  *docket
/+  *server, default-agent, dbug, multipart
|%
+$  versioned-state
  $%  state-0
  ==
+$  site  [link=path =part:multipart]
+$  state-0  [%0 sites=(list site)]
--
%-  agent:dbug
=|  state-0
=*  state  -
=*  card  card:agent:gall
^-  agent:gall
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  :~  [%pass /bind-page %arvo %e %connect [~ /apps/page/upload] %page]
  ==
++  on-save  on-save:def
++  on-load  on-load:def
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  :: ~&  require-authenticated-simple
  ?+    mark
    (on-poke:def [mark vase])
  ::
      %handle-http-request
    :: TODO authenticate
    =/  req  !<  (pair @ta inbound-request:eyre)  vase
    ?+    method.request.q.req
      =/  data=octs
        (as-octs:mimes:html '<h1>405 Method Not Allowed</h1>')
      =/  content-length=@t
        (crip ((d-co:co 1) p.data))
      =/  =response-header:http
        :-  405
        :~  ['Content-Length' content-length]
            ['Content-Type' 'text/html']
            ['Allow' 'POST']
        ==
      :_  this
      :~
        [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
        [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`data)]
        [%give %kick [/http-response/[p.req]]~ ~]
      ==
        %'GET'
      =/  link  (stab url.request.q.req)
      :: ~&  +.link
      =/  get-link  |=  =site  -.site
      =/  site-idx  (find (turn sites:this get-link) ~[+.link])
      =/  site  (snag +.site-idx sites.this)
      :: ~&  (snag 0 sites.this)
      :: ~&  (get-link (snag 0 sites.this))
      :: ~&  (turn sites.this |=(site link.site))
      ~&  (crip +.type.part.site)

      =/  data=octs
        (as-octs:mimes:html body.part.site)
      =/  content-length=@t
        (crip ((d-co:co 1) p.data))
      =/  =response-header:http
        :-  200
        :~  ['Content-Length' content-length]
            ['Content-Type' (crip +.type.part.site)]
        ==
      :_  this
      :~
        [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
        [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`data)]
        [%give %kick [/http-response/[p.req]]~ ~]
      ==
      ::
        %'POST'
      ::
      =/  body  body.request.q.req
      =/  header-list  header-list.request.q.req
      =/  parts  (de-request:multipart header-list body)
      =/  file   (snag 0 u.+.parts)
      =/  link   (snag 1 u.+.parts)
      =/  link-path  (stab body.link)
      :: TODO validate link and file
      =/  new-sites  (snoc sites:this [link-path +.file])
      :_  this(sites new-sites)
      [%pass link-path %arvo %e %connect [~ (into link-path 0 'pages')] %page]~
      :: :~
      ::   [%give %kick [/http-response/[p.req]]~ ~]
      :: ==
    ==
  ==
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path
    (on-watch:def path)
  ::
      [%http-response *]
    %-  (slog leaf+"Eyre subscribed to {(spud path)}." ~)
    `this
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  ?=([%bind-foo ~] wire)
    (on-arvo:def [wire sign-arvo])
  ?>  ?=([%eyre %bound *] sign-arvo)
  ?:  accepted.sign-arvo
    %-  (slog leaf+"/foo bound successfully!" ~)
    `this
  %-  (slog leaf+"Binding /foo failed!" ~)
  `this
++  on-fail   on-fail:def
--
