/* See LICENSE file for copyright and license details. */

#define COLORBAR

/* appearance */
static const char font[]            = "-*-terminus-medium-r-*-*-16-*-*-*-*-*-*-*";
static const char normbordercolor[] = "#dddddd";
static const char normbgcolor[]     = "#222222";
static const char normfgcolor[]     = "#eeeeee";
static const char selbordercolor[]  = "#ffffff";
static const char selbgcolor[]      = "#333333";
static const char selfgcolor[]      = "#ffffff";
#ifdef COLORBAR
static const char* colors[NumColors][ColLast] = {
	// border          foreground   background
	{ normbordercolor, normfgcolor, normbgcolor },  // normal
	{ selbordercolor,  selfgcolor,  selbgcolor  },  // selected

	{ normbordercolor, selbgcolor,  selfgcolor  },  // warning
	{ normbordercolor, "#ffffff",   "#ff0000"   },  // error
	{ normbordercolor, "#7598b2",   normbgcolor },  // delim

        { normbordercolor, "#b10000",   normbgcolor },  // hot
	{ normbordercolor, "#b15c00",   normbgcolor },  // medium
	{ normbordercolor, "#6cb100",   normbgcolor },  // cool
};
#endif
static const unsigned int borderpx  = 0;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const double shade	    = 0.6;      /* opacity of unfocussed clients */
static const unsigned int gappx     = 0;

static const Bool showbar           = False;    /* False means no bar */
static const Bool topbar            = True;     /* False means bottom bar */
static const int nmaster            = 1;        /* default number of clients in the master area */

static const Rule rules[] = {
	/* class                  instance    title       tags mask     isfloating   monitor   opacity */
	{ "Chromium",             NULL,       NULL,       1 << 3,       False,       -1,       -1 },
	{ "Firefox",              NULL,       NULL,       1 << 3,       False,       -1,       -1 },
	{ "Gajim",                NULL,       NULL,       1 << 2,       False,       -1,       -1 },
	{ "Gimp",                 NULL,       NULL,       0,            True,        -1,       -1 },
	{ "Dia",                  NULL,       NULL,       0,            True,        -1,       -1 },
	{ "Inkscape",             NULL,       NULL,       0,            True,        -1,       -1 },

	{ "libreoffice-calc",     NULL,       NULL,       0,            True,        -1,       -1 },
	{ "libreoffice-writer",   NULL,       NULL,       0,            True,        -1,       -1 },

    /*
	{ "Firefox",  NULL,       NULL,       1 << 8,       False,       -1,       -1 },
	{ "URxvt",    NULL,       NULL,       0,            False,       -1,       0.95  },
    */
};

/* layout(s) */
static const float mfact      = 0.50; /* factor of master area size [0.05..0.95] */
static const Bool resizehints = False; /* True means respect size hints in tiled resizals */
static const float attachmode = AttAsFirst; /* Attach Mode */

/* addons: layouts */
#include "layouts/nbstack.c"       /* bottom stack (tiling) */
#include "layouts/bstackhoriz.c"   /* bottom stack (tower like stack)  */
#include "layouts/grid.c"          /* regular grid */
#include "layouts/gaplessgrid.c"   /* best fitting grid */
#include "layouts/fibonacci.c"     /* spiral like arrangement */

static const Layout layouts[] = {
	/* symbol     gap?    arrange function */
	{ "[]=",      True,   ntile },    /* first entry is default */
	{ "><>",      False,  NULL },    /* no layout function means floating behavior */
	{ "[M]",      False,  monocle },
	{ "TTT",      True,   nbstack },
	{ "###",      True,   gaplessgrid },
	{ "+++",      True,   grid },
	{ "===",      True,   bstackhoriz },
	{ "(@)",      True,   spiral },
	{ "[\\]",     True,   dwindle },
};

/* tagging */
static const Tag tags[] = {
	/* name layout       mfact, showbar, topbar, attachmode, nmaster */
	{ "1", &layouts[2],  -1,    -1,      -1,     -1,         -1 },
	{ "2", &layouts[2],  -1,    -1,      -1,     -1,         -1 },
	{ "3", &layouts[1],  -1,    -1,      -1,     -1,         -1 },
	{ "4", &layouts[2],  -1,    -1,      -1,     -1,         -1 },
	{ "5", &layouts[2],  -1,    -1,      -1,     -1,         -1 },
	{ "6", &layouts[2],  -1,    -1,      -1,     -1,         -1 },
	{ "7", &layouts[1],  -1,    -1,      -1,     -1,         -1 },
	{ "8", &layouts[1],  -1,    -1,      -1,     -1,         -1 },
	{ "9", &layouts[1],  -1,    -1,      -1,     -1,         -1 },
	{ "10", &layouts[1], -1,    -1,      -1,     -1,         -1 },
	{ "11", &layouts[1], -1,    -1,      -1,     -1,         -1 },
	{ "12", &layouts[1], -1,    -1,      -1,     -1,         -1 },
};

/* addons: other */
#include "other/togglemax.c"
#include "other/push.c"

/* key definitions */
//#define MODKEY Mod1Mask
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *dmenucmd[] = { "dmenu_run", "-fn", font, "-nb", normbgcolor, "-nf", normfgcolor, "-sb", selbgcolor, "-sf", selfgcolor, NULL };
static const char *termcmd[]  = { "st", NULL };
static const char *suspendcmd[]  = { "systemctl", "suspend", "-i", NULL };
static const char *brightnessup[]  = { "sudo", "brightness", "up", NULL };
static const char *brightnessdown[]  = { "sudo", "brightness", "down", NULL };
static const char *volumeup[]  = { "amixer", "set", "Master", "5%+", NULL };
static const char *volumedown[]  = { "amixer", "set", "Master", "5%-", NULL };

static Key keys[] = {
	/* modifier                     key        function        argument */
    { 0,                            0x1008ff2f, spawn,         {.v = suspendcmd } },
    { 0,                            0x1008ff02, spawn,         {.v = brightnessup } },
    { 0,                            0x1008ff03, spawn,         {.v = brightnessdown } },
    { 0,                            0x1008ff13, spawn,         {.v = volumeup } },
    { 0,                            0x1008ff11, spawn,         {.v = volumedown } },
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ControlMask,           XK_j,      pushdown,       {0} },
    { MODKEY|ControlMask,           XK_k,      pushup,         {0} },
	{ MODKEY,                       XK_plus,   zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
	{ MODKEY|ShiftMask,             XK_t,      setlayout,      {.v = &layouts[0]} }, /*ntile*/
	{ MODKEY|ShiftMask,             XK_f,      setlayout,      {.v = &layouts[1]} }, /*float*/
	{ MODKEY|ShiftMask,             XK_m,      setlayout,      {.v = &layouts[2]} }, /*monocle*/
	{ MODKEY|ShiftMask,             XK_b,      setlayout,      {.v = &layouts[3]} }, /*bottomstack*/
	{ MODKEY|ShiftMask,             XK_g,      setlayout,      {.v = &layouts[4]} }, /*gaplessgrid*/
	{ MODKEY|ShiftMask,             XK_r,      setlayout,      {.v = &layouts[5]} }, /*grid*/
	{ MODKEY|ShiftMask,             XK_h,      setlayout,      {.v = &layouts[6]} }, /*bstackhoriz*/
	{ MODKEY|ShiftMask,             XK_p,      setlayout,      {.v = &layouts[7]} }, /*spiral*/
	{ MODKEY|ShiftMask,             XK_d,      setlayout,      {.v = &layouts[8]} }, /*dwindle*/
	{ MODKEY|ShiftMask,             XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_h,      incnmaster,     {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_l,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_x,      setnmaster,     {.i = 1 } },
	{ MODKEY|ControlMask,           XK_q,      setattachmode,  {.i = AttAsFirst } },
	{ MODKEY|ControlMask,           XK_m,      setattachmode,  {.i = AttAsLast } },
	{ MODKEY|ControlMask,           XK_1,      setattachmode,  {.i = AttAbove } },
	{ MODKEY|ControlMask,           XK_a,      setattachmode,  {.i = AttBelow } },
	{ MODKEY|ControlMask,           XK_w,      setattachmode,  {.i = AttAside } },
	{ MODKEY,                       XK_Tab,    focustoggle,    {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	//{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	//{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	//{ MODKEY,                       XK_Left,   nexttag,        {.i = -1 } },
	//{ MODKEY,                       XK_Right,  nexttag,        {.i = +1 } },
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
	TAGKEYS(                        XK_F10,                    9)
	TAGKEYS(                        XK_F11,                    10)
	TAGKEYS(                        XK_F12,                    11)
	{ MODKEY|ShiftMask,             XK_q,      quit,           {.i = 0} },
	{ MODKEY|ControlMask,           XK_q,      quit,           {.i = 23} },
};

/* button definitions */
/* click can be ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button1,        focusonclick,   {0} },
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
