/* See LICENSE file for copyright and license details. */

/* appearance */
static const char font[]            = "-*-terminus-medium-r-*-*-16-*-*-*-*-*-*-*";
static const char normbordercolor[] = "#dddddd";
static const char normbgcolor[]     = "#222222";
static const char normfgcolor[]     = "#eeeeee";
static const char selbordercolor[]  = "#ffffff";
static const char selbgcolor[]      = "#333333";
static const char selfgcolor[]      = "#ffffff";
static const unsigned int borderpx  = 0;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const Bool showbar           = False;    /* False means no bar */
static const Bool topbar            = True;     /* False means bottom bar */
static const unsigned int forcewidth  = 0;
static const unsigned int forceheight = 0;
static const unsigned int max_monitors = 2;

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9",
	                          "10", "11", "12" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,            True,        -1 },
	{ "Firefox",  NULL,       NULL,       1 << 8,       False,       -1 },
	{ "Chromium", NULL,       NULL,       1 << 3,       False,        0 },
	{ "Firefox",  NULL,       NULL,       1 << 5,       False,       -1 },
	{ "Gajim",    NULL,       NULL,       1 << 2,       False,       -1 },
	{ "Gimp",     NULL,       NULL,       0,            True,        -1 },
	{ "Dia",      NULL,       NULL,       0,            True,        -1 },
	{ "Inkscape", NULL,       NULL,       0,            True,        -1 },
	{ "MPlayer",  NULL,       NULL,       0,            True,         0 },
	{ "mpv",      NULL,       NULL,       0,            True,         0 },
	{ "ffplay",   NULL,       NULL,       0,            True,         0 },
	{ "libreoffice-calc", NULL, NULL,     0,            True,        -1 },
	{ "libreoffice-writer", NULL, NULL,   0,            True,        -1 },
	{ "mednafen", NULL,       NULL,       0,            False,        0 },
};

/* layout(s) */
static const float mfact      = 0.80; /* factor of master area size [0.05..0.95] */
static const int nmaster      = 1;    /* number of clients in master area */
static const Bool resizehints = False; /* True means respect size hints in tiled resizals */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "[M]",      monocle },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[+]",      centered },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
/* NOTE: require newer version of dmenu */
//static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", font, "-nb", normbgcolor, "-nf", normfgcolor, "-sb", selbgcolor, "-sf", selfgcolor, NULL };
static const char *dmenucmd[] = { "dmenu_run", "-fn", font, "-nb", normbgcolor, "-nf", normfgcolor, "-sb", selbgcolor, "-sf", selfgcolor, NULL };
static const char *termcmd[]  = { "st", NULL };
static const char *suspendcmd[]  = { "systemctl", "suspend", "-i", NULL };
static const char *brightnessup[]  = { "sudo", "brightness", "up", NULL };
static const char *brightnessdown[]  = { "sudo", "brightness", "down", NULL };
static const char *volumeup[]  = { "amixer", "set", "Master", "2%+", NULL };
static const char *volumedown[]  = { "amixer", "set", "Master", "2%-", NULL };
static const char *volumemute[]  = { "amixer", "set", "Master", "toggle", NULL };
static const char *display[]  = { "xrandr-auto", NULL };
static const char *switchkbd[]  = { "switchkbd", NULL };

static Key keys[] = {
	/* modifier                     key        function        argument */
	{ 0,                            0x1008ff2f, spawn,         {.v = suspendcmd } },
	{ 0,                            0x1008ff02, spawn,         {.v = brightnessup } },
	{ 0,                            0x1008ff03, spawn,         {.v = brightnessdown } },
	{ 0,                            0x1008ff13, spawn,         {.v = volumeup } },
	{ 0,                            0x1008ff11, spawn,         {.v = volumedown } },
	{ 0,                            0x1008ff12, spawn,         {.v = volumemute } },
	{ 0,                            0x1008ff59, spawn,         {.v = display } },
	{ 0,                            0x1008ff4a, spawn,         {.v = switchkbd } },
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} }, /*ntile*/
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[2]} }, /*float*/
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[1]} }, /*monocle*/
	{ MODKEY,                       XK_c,      setlayout,      {.v = &layouts[3]} }, /*centered*/
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	TAGKEYS(                        XK_F1,                     0)
	TAGKEYS(                        XK_F2,                     1)
	TAGKEYS(                        XK_F3,                     2)
	TAGKEYS(                        XK_F4,                     3)
	TAGKEYS(                        XK_F5,                     4)
	TAGKEYS(                        XK_F6,                     5)
	TAGKEYS(                        XK_F7,                     6)
	TAGKEYS(                        XK_F8,                     7)
	TAGKEYS(                        XK_F9,                     8)
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
	/* extra desktops */
	TAGKEYS(                        XK_F10,                    9)
	TAGKEYS(                        XK_F11,                    10)
	TAGKEYS(                        XK_F12,                    11)
};

/* button definitions */
/* click can be ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
