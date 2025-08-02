mapsList = [];

loadArenaFiles()
{
    files = FS_ListFiles("mp", "*.arena");
    if(!isdefined(files))
        return;

    for(i = 0; i < files.size; i++)
    {
        path = "mp/" + files[i];
        handle = FS_FOpen(path, "read");
        if(handle < 0)
            continue;

        mapname = undefined;
        gametypes = [];

        while(1)
        {
            line = FS_FReadLine(handle);
            if(!isdefined(line))
                break;

            line = strip(line);
            if(line == "" || line == "{" || line == "}")
                continue;

            if(getsubstr(line, 0, 3) == "map")
            {
                tokens = explode(line, "\"");
                if(tokens.size > 1)
                    mapname = tokens[1];
            }
            else if(getsubstr(line, 0, 8) == "gametype")
            {
                tokens = explode(line, "\"");
                if(tokens.size > 1)
                    gametypes = explode(tokens[1], " ");
            }
        }

        FS_FClose(handle);

        if(isdefined(mapname) && gametypes.size)
            mapsList[mapname] = gametypes;
    }
}
