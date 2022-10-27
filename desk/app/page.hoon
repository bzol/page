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
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-state)
  ?-  -.old
    %0  `this(state old)
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark
    (on-poke:def [mark vase])
  ::
      %handle-http-request
    =/  req  !<  (pair @ta inbound-request:eyre)  vase
    ?.  |(authenticated.q.req =(method.request.q.req %'GET'))
      =/  =response-header:http
        :-  307
        :~  ['location' '/~/login?redirect=']
        ==
      :_  this
        [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]~
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
      =/  get-link  |=  =site  -.site
      =/  site-idx  (find ~[+.link] (turn sites:this get-link))
      ?~  site-idx  !!
      =/  site  (snag +.site-idx sites.this)
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
      =/  body  body.request.q.req
      =/  header-list  header-list.request.q.req
      =/  parts  (de-request:multipart header-list body)
      =/  link   (snag 0 u.+.parts)
      =/  file   (snag 1 u.+.parts)
      =/  link-path  (stab body.link)
      =/  delete-idx  (find ~[link-path] (turn sites:this |=(=site link.site)))
      =/  new-sites  
        ?~  delete-idx  
          (snoc sites:this [link-path +.file])
        =/  deleted-sites  (oust [+.delete-idx 1] sites.this)
        (snoc deleted-sites [link-path +.file])
      :_  this(sites new-sites)
      [%pass link-path %arvo %e %connect [~ (into link-path 0 'p')] %page]~
      ::
        %'DELETE'
      =/  link-header  (snag 3 header-list.request.q.req)
      =/  site-idx  (find ~[(stab +.link-header)] (turn sites:this |=(=site link.site)))
      =/  new-sites  (oust [+.site-idx 1] sites.this)
      =/  link-path  (stab +.link-header)
      :_  this(sites new-sites)
      [%pass link-path %arvo %e %disconnect [~ (into link-path 0 'p')]]~
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
  ?+    path  (on-peek:def path)
      [%x %sites ~]  
    =/  sites-json
      [%a (turn sites.this |=(=site [%s (spat link.site)]))]
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
