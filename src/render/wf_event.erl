-module(wf_event).
-author('Maxim Sokhatsky').
-include_lib ("nitro/include/nitro.hrl").
-compile(export_all).

-record(ev, { module, msg, trigger, name }).
-record(cx, { handlers, actions, req, module, lang, path, session, params, form, state=[] }).
-define(CTX, (get(context))).

new(P,E,D,N,Data,Source) -> new(P,E,D,N,Data,Source,<<>>).

new(bin,Data) -> <<"ws.send(enc(tuple(atom('bin'),bin('",(nitro:pickle(Data))/binary,"'))));">>.
new(undefined, _, _, _, _, _, _) -> <<>>;

new({submitSemanticForm,Form}=Postback, Element, Delegate, Name, Data, Source, Validation) ->
    Module = nitro:coalesce([Delegate, ?CTX#cx.module]),
    Join=fun([]) -> []; ([E]) -> [$'|E]++[$'];
        ([H|T]) -> [[$'|H]++[$']] ++ [ [$,,$'|E]++[$'] || E <- T ] end,
    Event = #ev{name=Name, module=Module, msg=Postback, trigger=Element},
    erlang:list_to_binary([ <<"{ if (validateSemanticForm('">>, nitro:to_binary(Form), <<"',[">>,
    Join([ case is_atom(S) of true -> atom_to_list(S); false -> S end || S <- Source, S =/= []]),
    <<"])) { ">>,nitro:to_binary(Validation),<<" ws.send(enc(tuple(atom('">>,
    nitro:to_binary(application:get_env(n2o,event,pickle)),<<"'),bin('">>,Element,<<"'),bin('">>,
    nitro:pickle(Event),<<"'),">>,Data,<<"))); } else console.log('Validation Error'); }">> ]);
    
new(Postback, Element, Delegate, Name, Data, Source, Validation) ->
    Module = nitro:coalesce([Delegate, ?CTX#cx.module]),
    Join=fun([]) -> []; ([E]) -> [$'|E]++[$'];
        ([H|T]) -> [[$'|H]++[$']] ++ [ [$,,$'|E]++[$'] || E <- T ] end,
    Event = #ev{name=Name, module=Module, msg=Postback, trigger=Element},
    erlang:list_to_binary([ <<"{ if (validateSources([">>,
        Join([ case is_atom(S) of true -> atom_to_list(S); false -> S end || S <- Source, S =/= []]),
        <<"])) { ">>,nitro:to_binary(Validation),<<" ws.send(enc(tuple(atom('">>,
        nitro:to_binary(application:get_env(n2o,event,pickle)),<<"'),bin('">>,Element,<<"'),bin('">>,
        nitro:pickle(Event),<<"'),">>,Data,<<"))); } else console.log('Validation Error'); }">> ]).
