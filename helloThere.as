const string helloThere = "music/hellothere.mp3";

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("JustJ4Y, Megaraptor38");
    g_Module.ScriptInfo.SetContactInfo("https://github.com/JustJ4Y/Sven-Coop-Server-Plugins");

    // Chat-Hook registrieren
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
}

void MapInit()
{
	g_Game.PrecacheGeneric( "sound/" + helloThere );
	g_SoundSystem.PrecacheSound( helloThere );
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
    g_Scheduler.SetTimeout( "Play", 3 );
    return HOOK_CONTINUE;
}

void Play()
{
    g_SoundSystem.PlaySound(g_EntityFuncs.IndexEnt(0), CHAN_MUSIC, helloThere, 1.0f, 0.0f);
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "General Kenobi!\n");
}