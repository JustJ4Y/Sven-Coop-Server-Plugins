const string killSound = "as_scripts/pling.wav";

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("JustJ4Y, Megaraptor38");
    g_Module.ScriptInfo.SetContactInfo("https://github.com/JustJ4Y/Sven-Coop-Server-Plugins");

    g_Hooks.RegisterHook(Hooks::Monster::MonsterKilled, @OnMonsterKilled);
}

void MapInit()
{
	g_Game.PrecacheGeneric( "sound/" + killSound );
	g_SoundSystem.PrecacheSound( killSound );
}

HookReturnCode OnMonsterKilled(CBaseMonster@ pMonster, CBaseEntity@ pAttacker, int iGib)
{
    string mon = "<unknown monster>";
    if (pMonster !is null)
        mon = pMonster.m_FormattedName;

    string attacker = "<unknown>";
    CBasePlayer@ pl = null;

    if (pAttacker !is null)
    {
        @pl = cast<CBasePlayer@>(pAttacker);
        if (pl !is null)
        {
            attacker = pl.pev.netname;
        }
        else
        {
            CBaseMonster@ mon = cast<CBaseMonster@>(pAttacker);
            if (mon !is null)
            {
                attacker = mon.m_FormattedName;
            }
            else
            {
                attacker = pAttacker.GetClassname();
            }
        }
    }

    if (pl !is null)
    {
        g_SoundSystem.EmitSound( pl.edict(), CHAN_ITEM, killSound, 1.0f, 3.0f );
    }

    g_PlayerFuncs.ClientPrintAll(HUD_PRINTNOTIFY, mon + " was killed by " + attacker + "\n");
    return HOOK_CONTINUE;
}