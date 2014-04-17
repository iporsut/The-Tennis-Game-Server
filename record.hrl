-record(client, {
        id,
        name = "",
        state = wait
    }).

-record(server, {
        clients = [],
        playing_matches = [],
        waiting_matches = []
    }).
