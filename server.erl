-module(server).

-export([start/0, stop/0]).

-include_lib("record.hrl").

start() ->
    register(server,
        spawn(fun() -> loop(#server{}) end)).

stop() ->
    server ! stop,
    unregister(server).

loop(State) ->
    receive
        stop -> void;
        {Client, message, Message} ->
            Client ! {ok, Message},
            loop(State);
        {Client, waiting_matches} ->
            Client ! {ok, State#server.waiting_matches},
            loop(State);
        {Client, playing_matches} ->
            Client ! {ok, State#server.playing_matches},
            loop(State);
        {Client, create_match, Name} ->
            CurrentWaitingMatches = State#server.waiting_matches,
            case lists:keyfind(Name, 1, CurrentWaitingMatches) of
                false ->
                    NewWaitingMatches = CurrentWaitingMatches ++ [{Name,{Client}}],
                    Client ! ok,
                    NewState = State#server{waiting_matches = NewWaitingMatches},
                    loop(NewState)
                    ;
                _Match ->
                    Client ! {err, "Existed match name."},
                    loop(State)
            end;
        {Client, connect_to_match, Name} ->
            CurrentWaitingMatches = State#server.waiting_matches,
            CurrentPlayingMatches = State#server.playing_matches,
            case lists:keyfind(Name, 1, CurrentWaitingMatches) of
                false ->
                    Client ! {err, "Dosen't Existed match."},
                    loop(State);
                Match ->
                    NewWaitingMatches = CurrentWaitingMatches -- [Match],
                    {Name, {ClientWating}} = Match,
                    NewPlayingMatches = CurrentPlayingMatches ++ [{Name, {ClientWating, Client}}],
                    NewState = State#server{playing_matches = NewPlayingMatches, waiting_matches = NewWaitingMatches},
                    Client ! ok,
                    loop(NewState)
            end;
        {Client, connect} ->
            Clients = State#server.clients,
            NewState = State#server{clients = Clients ++ [Client]},
            loop(NewState)
    end.
