-module(client).

-export([messageToServer/1,
        list_waiting_matches/0,
        create_match/1,
        connect_to_match/1,
        list_playing_matches/0
    ]).

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

