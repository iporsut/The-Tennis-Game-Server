-module(client).

-export([new/0
    ]).

new() -> 
    spawn(fun() -> client_loop() end).

client_loop() ->
    receive
        {messageToServer, Message} -> 
            messageToServer(Message),
            client_loop();
        {list_waiting_matches} -> 
            list_waiting_matches(),
            client_loop();
        {list_playing_matches} ->
            list_playing_matches(),
            client_loop();
        {create_match, Name} ->
            create_match(Name),
            client_loop();
        {connect_to_match, Name} ->
            connect_to_match(Name),
            client_loop()
    end.

messageToServer(Message) ->
    server ! {self(), message, Message},
    receive
        {ok, Message} ->
            io:format("~p~n", [Message])
    after 5000 ->
            io:format("Request Message To Server Timeout.~n")
    end.

list_waiting_matches() ->
    server ! {self(), waiting_matches},
    receive
        {ok, Matches} ->
            io:format("~p~n", [Matches])
    after 5000 ->
            io:formats("Request List Waiting Matches Timeout.~n")
    end.

list_playing_matches() ->
    server ! {self(), playing_matches},
    receive
        {ok, Matches} ->
            io:format("~p~n", [Matches])
    after 5000 ->
            io:formats("Request List Playing Matches Timeout.~n")
    end.

create_match(Name) ->
    server ! {self(), create_match, Name},
    receive
        ok ->
            io:format("Matches Created Wait for another player.~n");
        {err, Message} ->
            io:format("Error: ~s~n",[Message])

    after 5000 ->
            io:format("Request Create Match Timeout.~n")
    end.

connect_to_match(Name) ->
    server ! {self(), connect_to_match, Name},
    receive
        ok ->
            io:format("Connected Match ~s waiting your turn.~n",[Name]);
        {err, Message} ->
            io:format("Error: ~s~n", [Message])
    after 5000 ->
            io:format("Request Connect match Timeout.~n")
    end.

