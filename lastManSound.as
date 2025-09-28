const string szLastManMusic = "music/lastMan.mp3";

void PluginInit(){
    g_Module.ScriptInfo.SetAuthor("JustJ4Y, Megaraptor38");
    g_Module.ScriptInfo.SetContactInfo("https://github.com/JustJ4Y/Sven-Coop-Server-Plugins");

    g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @PlayerKilled);
    g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
    g_Hooks.RegisterHook(Hooks::Player::PlayerRevived, @PlayerRevived);
}

void MapInit(){
	g_Game.PrecacheGeneric( "sound/" + szLastManMusic );
	g_SoundSystem.PrecacheSound( szLastManMusic );
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib ){
    uint aliveCount = 0;
    uint connectedCount = 0;

    for (int i = 1; i <= g_Engine.maxClients; i++){
        CBasePlayer@ pOther = g_PlayerFuncs.FindPlayerByIndex(i);
        if (pOther !is null && pOther.IsConnected()){
            connectedCount++;
            if (pOther.IsAlive())
                aliveCount++;
        }
    }

    if (aliveCount == 1){
        Play();
    }
    else{
        Stop();
    }

    g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Players] Alive: " + aliveCount + " / Connected: " + connectedCount + "\n");

    return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer ){
    Stop();
    return HOOK_CONTINUE;
}

HookReturnCode PlayerRevived( CBasePlayer@ pPlayer ){
    Stop();
    return HOOK_CONTINUE;
}

void Play()
{
	g_SoundSystem.PlaySound(g_EntityFuncs.IndexEnt(0), CHAN_MUSIC, szLastManMusic, 1.0f, 0.0f, SND_FORCE_LOOP);
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK,"Only one living player left!\n");
}

void Stop()
{
	g_SoundSystem.StopSound(g_EntityFuncs.IndexEnt(0), CHAN_MUSIC, szLastManMusic);
}