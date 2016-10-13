-module(element_select).
-include_lib("nitro/include/nitro.hrl").
-compile(export_all).

render_element(Record = #select{}) ->
  ID = case Record#select.id of undefined -> nitro:temp_id(); I->I end,
  case Record#select.postback of
    undefined -> skip;
    Postback -> nitro:wire(#event{ type=change,
                                target=ID,
                                postback=Postback,
                                source=[nitro:to_atom(ID)],
                                delegate=Record#select.delegate }) end,
  Props = [
    {<<"id">>, ID},
    {<<"class">>, Record#select.class},
    {<<"style">>, Record#select.style},
    {<<"name">>, Record#select.name},
    {<<"onchange">>, Record#select.onchange},
    {<<"title">>, Record#select.title},
    {<<"disabled">>, case Record#select.disabled of true -> <<"disabled">>; _-> undefined end},
    {<<"multiple">>, case Record#select.multiple of true -> <<"multiple">>; _-> undefined end} | Record#select.data_fields
  ],
  wf_tags:emit_tag(<<"select">>, nitro:render(Record#select.body),
                                  Props);
render_element(Group = #optgroup{}) ->
  wf_tags:emit_tag(<<"optgroup">>, nitro:render(Group#optgroup.body), [
    {<<"disabled">>, case Group#optgroup.disabled of true-> <<"disabled">>; _-> undefined end},
    {<<"label">>, Group#optgroup.label}
  ]);
render_element(O = #option{}) ->
  wf_tags:emit_tag(<<"option">>, nitro:render(O#option.body), [
    {<<"id">>, O#option.id},
    {<<"disabled">>, O#option.disabled},
    {<<"label">>, O#option.label},
    {<<"title">>, O#option.title},
    {<<"selected">>, case O#option.selected of true -> <<"selected">>; _-> undefined end},
    {<<"value">>, O#option.value} | O#option.data_fields]).
