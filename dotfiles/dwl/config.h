/* dwl config.h - Artix Suckless Workstation
 * Version: 1.0
 * Pure Monochrome Aesthetics & Keyboard-driven Workflow
 */

#include <X11/XF86keysym.h>

/* Appearance */
static const int sloppyfocus               = 1;  /* focus follows mouse */
static const int bypass_surface_visibility = 0;  /* 1 means idle inhibitors will disable idle tracking even if surface isn't visible */
static const unsigned int borderpx         = 1;  /* border pixel of windows */
static const float rootcolor[]             = {0.0f, 0.0f, 0.0f, 1.0f};

/* Monochrome Palette */
static const char normfgcolor[]            = "#ffffff";
static const char normbgcolor[]            = "#000000";
static const char selfgcolor[]             = "#000000";
static const char selbgcolor[]             = "#808080";

/* Workspaces / Tags */
static const char *tags[] = { "1", "2", "3", "4", "5" };

/* Commands */
static const char *termcmd[]    = { "foot", NULL };
static const char *menucmd[]     = { "fuzzel", NULL };
static const char *browsercmd[]  = { "zen-browser", NULL };
static const char *lockcmd[]     = { "swaylock", NULL };
static const char *shotcmd[]     = { "sh", "-c", "grim -g \"$(slurp)\" ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png", NULL };
static const char *clipcmd[]     = { "sh", "-c", "cliphist list | fuzzel | cliphist decode | wl-copy", NULL };
static const char *layoutcmd[]   = { "fcitx5-remote", "-t", NULL };
static const char *volup[]       = { "pamixer", "-i", "5", NULL };
static const char *voldown[]     = { "pamixer", "-d", "5", NULL };
static const char *volmute[]     = { "pamixer", "-t", NULL };
static const char *brightup[]    = { "brightnessctl", "set", "+10%", NULL };
static const char *brightdown[]  = { "brightnessctl", "set", "10%-", NULL };

/* Keybindings Modifier */
#define MODKEY WLR_MODIFIER_LOGO
#define SHIFT  WLR_MODIFIER_SHIFT
#define CTRL   WLR_MODIFIER_CTRL

static const Key keys[] = {
	/* modifier                  key                 function        argument */
	{ MODKEY,                    XKB_KEY_space,      spawn,          {.v = menucmd} },
	{ MODKEY,                    XKB_KEY_t,          spawn,          {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_b,          spawn,          {.v = browsercmd} },
	{ MODKEY,                    XKB_KEY_q,          killclient,     {0} },
	{ MODKEY,                    XKB_KEY_l,          spawn,          {.v = lockcmd} },
	{ MODKEY,                    XKB_KEY_v,          spawn,          {.v = clipcmd} },
	{ MODKEY,                    XKB_KEY_space,      spawn,          {.v = layoutcmd} },
	{ 0,                         XKB_KEY_Print,      spawn,          {.v = shotcmd} },

	/* Hardware media keys */
	{ 0,                         XF86XK_AudioRaiseVolume, spawn,     {.v = volup} },
	{ 0,                         XF86XK_AudioLowerVolume, spawn,     {.v = voldown} },
	{ 0,                         XF86XK_AudioMute,        spawn,     {.v = volmute} },
	{ 0,                         XF86XK_MonBrightnessUp,   spawn,     {.v = brightup} },
	{ 0,                         XF86XK_MonBrightnessDown, spawn,     {.v = brightdown} },

	/* Workspaces 1..5 */
	{ MODKEY,                    XKB_KEY_1,          view,           {.ui = 1 << 0} },
	{ MODKEY,                    XKB_KEY_2,          view,           {.ui = 1 << 1} },
	{ MODKEY,                    XKB_KEY_3,          view,           {.ui = 1 << 2} },
	{ MODKEY,                    XKB_KEY_4,          view,           {.ui = 1 << 3} },
	{ MODKEY,                    XKB_KEY_5,          view,           {.ui = 1 << 4} },

	{ MODKEY|SHIFT,              XKB_KEY_1,          tag,            {.ui = 1 << 0} },
	{ MODKEY|SHIFT,              XKB_KEY_2,          tag,            {.ui = 1 << 1} },
	{ MODKEY|SHIFT,              XKB_KEY_3,          tag,            {.ui = 1 << 2} },
	{ MODKEY|SHIFT,              XKB_KEY_4,          tag,            {.ui = 1 << 3} },
	{ MODKEY|SHIFT,              XKB_KEY_5,          tag,            {.ui = 1 << 4} },
};
