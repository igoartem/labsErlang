-module(labs).
-author("artem").

%% API
-export([main/0, lab1/1, lab2/0, startTaxi/2, startLaundry/1, startRestorant/1, startManager/2, startClient/3,pinpong/0]).

div2([]) -> [];
div2([H | T]) -> [H / 2 | div2(T)].

main() -> lab2(),
  timer:sleep(300000).
%%main()-> pinpong().
%%main()-> lab1([minus, [multi, [plus, [divis, 4, 2], 5], 2], 10]).

lab1([plus, A, B]) -> lab1(A) + lab1(B);
lab1([minus, A, B]) -> lab1(A) - lab1(B);
lab1([multi, A, B]) -> lab1(A) * lab1(B);
lab1([divis, _, 0]) -> 0;
lab1([divis, A, B]) -> lab1(A) / lab1(B);
lab1(A) -> A.

%%  lists:seq(10,1,-1).

print(S) -> erlang:display(S).

%%pinpong() -> spawn(fun() -> ping(spawn(fun() -> pong() end)) end).
pinpong() -> spawn(fun() -> ping(spawn('ssssssss',proc, pong,[])) end).

ping(PidPong) ->
  io:format("Ping ~w ~w ~n", [PidPong, self()]),
  PidPong ! {ping, self()},
  receive
    pong -> io:format("Pong end")
  end,
  ping(PidPong).

pong() ->
  io:format("Pong ~w ~n", [self()]),
  receive
    {ping, PidPing} ->
      io:format("Pong"),
      PidPing ! pong
  end,
  pong().

clientStart(PidManager, PidRestorant) ->
  io:format("Client: start ~n"),
  PidManager ! {clientStart, self(), 1},
  receive
    {manager, PidManager, 0} ->
      io:format("Client: Exit and restart~n"),
      clientStart(PidManager, PidRestorant);
    {manager, PidManager, 1} ->
      io:format("Client: regist ok.. ~n"),
      client(PidManager, PidRestorant)
  end.

client(PidManager, PidRestorant) ->
  timer:sleep(1000),
  Rand = rand:uniform(4),
  io:format("Client ask: ~w ~n", [Rand]),
  if
    Rand == 1 ->
      PidRestorant ! {client, self()},
      client(PidManager, PidRestorant);
    true ->
      PidManager ! {client, self(), Rand}
  end,
  receive
    {manager, PidManager, 44} ->
      io:format("Client: Exit and restart ~n"),
      clientStart(PidManager, PidRestorant);

    {restorant, PidRestorant} ->
      io:format("Client: Ok restorant, yes.... ~n"),
      client(PidManager, PidRestorant);

    {manager, PidManager, 33} ->
      io:format("Client: Ok, launry... ~n"),
      client(PidManager, PidRestorant);

    {taxi, PidTaxi} ->
      io:format("Client: Ok taxi.... ~n"),
      client(PidManager, PidRestorant)

  end.

manager(PidLaundry, PidTaxi) ->
  io:format("Manager wait ~n"),
  receive
    {clientStart, PidClient, 1} ->
      io:format("Manager: Client regist ~n"),
      Rand = rand:uniform(1),
      io:format("Manager: ~w ~n", [Rand]),
      PidClient ! {manager, self(), Rand},
      manager(PidLaundry, PidTaxi);

    {client, PidClient, 2} ->
      io:format("Manager: Client to taxi ~n"),
      PidTaxi ! {manager, PidClient},
      manager(PidLaundry, PidTaxi);

    {client, PidClient, 3} ->
      io:format("Manager: client to laundry ~n"),
      PidLaundry ! {manager, self(), PidClient},
      manager(PidLaundry, PidTaxi);

    {laundry, PidLaundry, PidClient} ->
      io:format("Manager: laundry to client. ~n"),
      PidClient ! {manager, self(), 33},
      manager(PidLaundry, PidTaxi);

    {client, PidClient, 4} ->
      io:format("Manager: Client unrigister ~n"),
      PidClient ! {manager, self(), 44},
      manager(PidLaundry, PidTaxi)

%%    {laundry, PidClient} ->
%%      io:format("Manager: laundry accept ~n"),
%%      PidClient ! {manager, self()}
  end.

restorant() ->
  io:format("Wait Restorant ~n"),
  receive
    {client, PidClient} ->
      io:format("Restorant: Client to restorant ~n"),
      PidClient ! {restorant, self()},
      restorant()
  end.

laundry() ->
  io:format("Wait laundry ~n"),
  receive
    {manager, PidManager, PidClient} ->
      io:format("Laundry: Client to laundry ~n"),
      PidManager ! {laundry, self(), PidClient},
      laundry()
  end.

taxi() ->
  io:format("Wait taxi ~n"),
  receive
    {manager, PidClient} ->
      io:format("Taxi: Client to taxi ~n"),
      PidClient ! {taxi, self()},
      taxi()
  end.

lab2() ->
  PidLaundry = spawn(fun() -> laundry() end),
  PidTaxi = spawn(fun() -> taxi() end),
  PidManager = spawn(fun() -> manager(PidLaundry, PidTaxi) end),
  PidRestorant = spawn(fun() -> restorant() end),
  PidClient = spawn(fun() -> clientStart(PidManager, PidRestorant) end).

ping(_, pong) -> ok;
ping(Name, _) ->
  erlang:display(bred),
  timer:sleep(1000),
  ping(Name, net_adm:ping(Name)).

startTaxi(ClientNodeName, ManagerNodeName) ->
  global:register_name(taxi, self()),
  Nammm = global:registered_names(),
  io:format("~w ~n", [Nammm]),
  io:format("~w ~n", [self()]),
  ping(ClientNodeName, pang),
  ping(ManagerNodeName, pang),
  taxi().

startLaundry(ManagerNodeName) ->
  global:register_name(laundry, self()),
  Nammm = global:registered_names(),
  io:format("~w ~n", [Nammm]),
  io:format("~w ~n", [self()]),
  ping(ManagerNodeName, pang),
  laundry().

startRestorant(ClientNodeName) ->
  global:register_name(restorant, self()),
  ping(ClientNodeName, pang),
  restorant().

startManager(TaxiNodeName, LaundryNodeName) ->
  global:register_name(manager, self()),
  ping(TaxiNodeName, pang),
  ping(LaundryNodeName, pang),
  PidLaundry = global:whereis_name(laundry),
  PidTaxi = global:whereis_name(taxi),
  manager(PidLaundry, PidTaxi).

startClient(ManagerNodeName, RestorantNodeName, TaxiNodeName) ->
  global:register_name(client, self()),
  ping(ManagerNodeName, pang),
  ping(RestorantNodeName, pang),
  ping(TaxiNodeName, pang),
  PidManager = global:whereis_name(manager),
  PidRestorant = global:whereis_name(restorant),
  clientStart(PidManager, PidRestorant).

