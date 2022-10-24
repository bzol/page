/-  *docket
/+  *server, default-agent, dbug, multipart
|%
+$  versioned-state
  $%  state-0
  ==
+$  site  [link=path =part:multipart]
:: TODO add bundles
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
    :: TODO a commit deletes the state of the app
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
      =/  site-idx  (find ~[+.link] (turn sites:this get-link))
      ~&  +.link
      :: ~&  (find ~[+.link] (turn sites:this get-link)) 
      ~&  (turn sites:this get-link)
      ?~  site-idx
        ~&  'site-idx null'
        ~&  site-idx
        !!
      =/  site  (snag +.site-idx sites.this)
      ~&  site

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
      ~&  parts
      ~&  '-------'
      =/  link   (snag 0 u.+.parts)
      =/  file   (snag 1 u.+.parts)
      ~&  '-------'
      ~&  link
      =/  link-path  (stab body.link)
      :: =/  link-path  (stab (crip (weld (weld (trip body.link) "/") (trip +.file.file))))
      :: TODO validate link and file
      :: TODO replace existing site with new site if link is the same
      =/  new-sites  (snoc sites:this [link-path +.file])
      ~&  '=============='
      ~&  (into link-path 0 'pages')
      ~&  '=============='
      :_  this(sites new-sites)
      [%pass link-path %arvo %e %connect [~ (into link-path 0 'pages')] %page]~
      ::
        %'DELETE'
      =/  link-header  (snag 3 header-list.request.q.req)
      ~&  (turn sites:this |=(=site link.site))
      =/  site-idx  (find ~[(stab +.link-header)] (turn sites:this |=(=site link.site)))
      =/  new-sites  (oust [+.site-idx 1] sites.this)
      :: =/  link-path  (stab (crip (weld "/pages" (trip +.link-header))))
      =/  link-path  (stab +.link-header)
      ~&  link-path
      ~&  '+++++++++++'
      ~&  (into link-path 0 'pages')
      ~&  '+++++++++++'
      :_  this(sites new-sites)
      [%pass link-path %arvo %e %disconnect [~ (into link-path 0 '/pages')]]~
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
++  on-peek   
  |=  =path
  ^-  (unit (unit cage))
  ~&  'on-peek-called'
  ?+    path  (on-peek:def path)
      [%x %sites ~]  
    =/  sites-json
      [%a (turn sites.this |=(=site [%s (spat link.site)]))]
    ~&  sites-json
    :: ``json+!>([%a ~[[%s 'hello']]])
    ``json+!>(sites-json)
  ==
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
