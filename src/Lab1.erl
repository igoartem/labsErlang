%%%-------------------------------------------------------------------
%%% @author artoy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Февр. 2017 13:37
%%%-------------------------------------------------------------------
-module('Lab1').
-author("artoy").

%% API
-export([main/0, lab1/1]).

div2([]) -> [];
div2([H|T]) -> [H/2 | div2(T)].

main()-> lab2().
%%main()-> pinpong().
%%main()-> lab1([minus, [multi, [plus, [divis, 4, 2], 5], 2], 10]).

lab1([plus, A, B]) -> lab1(A) + lab1(B);
lab1([minus, A, B]) -> lab1(A) - lab1(B);
lab1([multi, A, B]) ->lab1(A) * lab1(B);
lab1([divis, _, 0])->0;
lab1([divis, A, B])->lab1(A) / lab1(B);
lab1(A) -> A.

%%  lists:seq(10,1,-1).

print(S)->erlang:display(S).

pinpong()-> spawn(fun()-> ping(spawn(fun()->pong() end)) end).

ping(PidPong)->
  io:format("Ping ~w ~w ~n", [PidPong, self()]),
  PidPong ! {ping, self()},
  receive
    pong->  io:format("Pong end")
  end,
  ping(PidPong).

pong()->
  io:format("Pong ~w ~n", [self()]),
  receive
    {ping, PidPing} ->
      io:format("Pong"),
      PidPing ! pong
  end,
  pong().

client(PidManager)->
  io:format("I am client ~n"),
  PidManager ! {client, self(), 1},
  receive
    {manager, PidManager, 0}->
          io:format("exit"),
          client(PidManager);

  {manager, PidManager, 1}->
      io:format("manager ok")

  end.


manager()->
  io:format("I am manager ~n"),
  receive
    {client, PidClient, Req}->
      if
        Req == 1 ->
          io:format("Client regist ~n"),
          Rand = rand:uniform(1),
          io:format("Answer ~w ~n", [Rand]),
          PidClient ! {manager, self(), Rand}
      end;
    {laundry}->
      io:format("laundry accept")
  end.

laundry(PidManager)->
  receive
    {manager}->
      io:format("manager request")
  end.

lab2()->
  PidManager = spawn(fun()->manager() end),
  PidClient = spawn(fun()->client(PidManager) end).