// empire_mod next-map history helpers extracted from legacy mapvote module

UpdateMapHistory()
{
        size = getcvarint("empire_map_history_size");
        if(!isdefined(size) || size <= 0)
                return;

        history = getRotationHistory();

        cur["map"] = getcvar("mapname");
        cur["gametype"] = getcvar("g_gametype");

	while(history.size >= size)
		history = removeRotationIndex(history, 0);

        history[history.size] = cur;

        setcvar("empire_map_history", buildRotationString(history));
}

UpdateGametypeHistory()
{
        size = getcvarint("empire_gametype_history_size");
        if(!isdefined(size) || size <= 0)
                return;

        history = getGametypeHistory();

        cur = getcvar("g_gametype");

	while(history.size >= size)
		history = removeRotationIndex(history, 0);

        history[history.size] = cur;

        setcvar("empire_gametype_history", buildGametypeString(history));
}

getRotationHistory()
{
        histstr = strip(getcvar("empire_map_history"));
        if(histstr == "")
                return [];

        tokens = explode(histstr, " ");
        hist = [];
        lastgt = getcvar("g_gametype");
        for(i=0;i<tokens.size;)
        {
                if(tokens[i] == "gametype" && isdefined(tokens[i+1]))
                {
                        lastgt = tokens[i+1];
                        i += 2;
                }
                else if(tokens[i] == "map" && isdefined(tokens[i+1]))
                {
                        hist[hist.size] = [];
                        hist[hist.size-1]["gametype"] = lastgt;
                        hist[hist.size-1]["map"] = tokens[i+1];
                        i += 2;
                }
                else
                        i++;
        }
        return hist;
}

buildRotationString(arr)
{
        str = "";
        for(i=0; i<arr.size; i++)
                str += " gametype " + arr[i]["gametype"] + " map " + arr[i]["map"];
        return strip(str);
}

getGametypeHistory()
{
        histstr = strip(getcvar("empire_gametype_history"));
        if(histstr == "")
                return [];

        return explode(histstr, " ");
}

buildGametypeString(arr)
{
        str = "";
        for(i=0; i<arr.size; i++)
                str += " " + arr[i];
        return strip(str);
}

removeRotationIndex(arr, index)
{
        newarr = [];
        for(i=0;i<arr.size;i++)
        {
                if(i != index)
                        newarr[newarr.size] = arr[i];
        }
        return newarr;
}
