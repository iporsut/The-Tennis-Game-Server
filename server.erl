-module(server).

-export([start/0, stop/0, message/2]).

start() ->
    register(server,
        spawn(fun() -> loop() end)).

stop() ->
    server ! stop.

message(Client, Message) ->
    server ! {Client, Message}.

loop() ->
    receive
        {Client, Message} ->
            Client ! Message,
            loop()
    end.
