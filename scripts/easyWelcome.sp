#include <sourcemod>

public Plugin:myinfo =
{
        name = " easy Welcome",
        author = "NiceT",
        description = "easy Welcome",
        version = "1.0",
        url = ""
}

public OnPluginStart()
{
        //nothing
}

public OnClientConnected(client)
{
        if(!IsFakeClient(client))
        {
                PrintToChatAll("\x04 %N \x01 is connecting!",client);
        }
}

public OnClientDisconnected(client)
{
        if(!IsFakeClient(client))
        {
                PrintToChatAll("\x04 %N \x01 was disconnected!",client);
        }
}
