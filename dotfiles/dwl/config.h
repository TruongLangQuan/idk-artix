/* dwl config.h - Artix Suckless Workstation
 * Version: 2.5 (9 Workspaces, Top Bar, Shiftview, TTY Switching, & Keybind Tutorial Popup)
 */

#include <X11/XF86keysym.h>

#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

/* Appearance */
static const int sloppyfocus               = 1;  /* focus follows mouse */
static const int bypass_surface_visibility = 0;  /* 1 means idle inhibitors will disable idle tracking even if surface isn't visible */
static const unsigned int borderpx         = 1;  /* border pixel of windows */
static const int showbar                   = 1;  /* 1 means show top bar */
static const int topbar                    = 1;  /* 1 means bar is at top */
static const char *fonts[]                 = {"monospace:size=10", "JetBrains Mono:size=10"};

static const float rootcolor[]             = COLOR(0x000000ff);
static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f};

static uint32_t colors[][3]                = {
	/*               fg          bg          border    */
	[SchemeNorm] = { 0xccccccff, 0x000000ff, 0x333333ff },
	[SchemeSel]  = { 0xffffffff, 0x222222ff, 0x808080ff },
	[SchemeUrg]  = { 0xffffffff, 0x000000ff, 0xff0000ff },
};

/* Tagging - 9 Workspaces */
static char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

/* Logging */
static int log_level = WLR_ERROR;

/* Rules */
static const Rule rules[] = {
	/* app_id          title       tags mask     isfloating   monitor */
	{ "Gimp",          NULL,       0,            1,           -1 },
	{ "foot-keybinds", NULL,       0,            1,           -1 },
};

/* Layouts */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* Monitors */
static const MonitorRule monrules[] = {
	{ NULL,       0.55f, 1,      1,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
};

/* Keyboard */
static const struct xkb_rule_names xkb_rules = {
	.options = NULL,
};

static const int repeat_rate = 25;
static const int repeat_delay = 600;

/* Trackpad & Mouse Input */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* Keybindings Modifier (Super Key) */
#define MODKEY WLR_MODIFIER_LOGO

#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

#define CHVT(n) \
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT, XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }, \
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT, XKB_KEY_F##n,             chvt, {.ui = (n)} }

/* Forward declaration for shiftview */
void shiftview(const Arg *arg);

/* Commands */
static const char *termcmd[]    = { "foot", NULL };
static const char *menucmd[]     = { "sh", "-c", "pkill -x fuzzel || fuzzel", NULL };
static const char *browsercmd[]  = { "zen-browser", NULL };
static const char *lockcmd[]     = { "swaylock", "-f", NULL };
static const char *shotcmd[]     = { "sh", "-c", "grim -g \"$(slurp)\" ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png", NULL };
static const char *clipcmd[]     = { "sh", "-c", "cliphist list | fuzzel | cliphist decode | wl-copy", NULL };
static const char *layoutcmd[]   = { "fcitx5-remote", "-t", NULL };
static const char *helpcmd[]     = { "keybind-help", NULL };
static const char *volup[]       = { "pamixer", "-i", "5", NULL };
static const char *voldown[]     = { "pamixer", "-d", "5", NULL };
static const char *volmute[]     = { "pamixer", "-t", NULL };
static const char *brightup[]    = { "brightnessctl", "set", "+10%", NULL };
static const char *brightdown[]  = { "brightnessctl", "set", "10%-", NULL };

static const Key keys[] = {
	/* modifier                  key                 function        argument */
	{ MODKEY,                    XKB_KEY_d,          spawn,          {.v = menucmd} },
	{ MODKEY,                    XKB_KEY_space,      spawn,          {.v = layoutcmd} },
	{ MODKEY,                    XKB_KEY_F1,         spawn,          {.v = helpcmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_H,          spawn,          {.v = helpcmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_slash,      spawn,          {.v = helpcmd} },
	{ MODKEY,                    XKB_KEY_f,          togglefullscreen,{0} },
	{ MODKEY,                    XKB_KEY_e,          togglefullscreen,{0} },
	{ MODKEY,                    XKB_KEY_s,          togglefloating, {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,      togglefloating, {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_T,          setlayout,      {.v = &layouts[0]} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_F,          setlayout,      {.v = &layouts[1]} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_M,          setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                    XKB_KEY_t,          spawn,          {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_Return,     spawn,          {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_b,          spawn,          {.v = browsercmd} },
	{ MODKEY,                    XKB_KEY_q,          killclient,     {0} },
	{ MODKEY,                    XKB_KEY_l,          spawn,          {.v = lockcmd} },
	{ MODKEY,                    XKB_KEY_v,          spawn,          {.v = clipcmd} },
	{ 0,                         XKB_KEY_Print,      spawn,          {.v = shotcmd} },

	/* Workspace Navigation via Super + Ctrl + Arrow & Ctrl + Shift + Arrow */
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_Right,      shiftview,      {.i = +1} },
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_Down,       shiftview,      {.i = +1} },
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_Left,       shiftview,      {.i = -1} },
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_Up,         shiftview,      {.i = -1} },
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT, XKB_KEY_Right, shiftview,{.i = +1} },
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT, XKB_KEY_Down,  shiftview,{.i = +1} },
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT, XKB_KEY_Left,  shiftview,{.i = -1} },
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT, XKB_KEY_Up,    shiftview,{.i = -1} },

	/* Hardware media keys */
	{ 0,                         XF86XK_AudioRaiseVolume, spawn,     {.v = volup} },
	{ 0,                         XF86XK_AudioLowerVolume, spawn,     {.v = voldown} },
	{ 0,                         XF86XK_AudioMute,        spawn,     {.v = volmute} },
	{ 0,                         XF86XK_MonBrightnessUp,   spawn,     {.v = brightup} },
	{ 0,                         XF86XK_MonBrightnessDown, spawn,     {.v = brightdown} },

	/* Layout & Focus keys */
	{ MODKEY,                    XKB_KEY_j,          focusstack,     {.i = +1} },
	{ MODKEY,                    XKB_KEY_k,          focusstack,     {.i = -1} },
	{ MODKEY,                    XKB_KEY_h,          setmfact,       {.f = -0.05f} },
	{ MODKEY,                    XKB_KEY_l,          setmfact,       {.f = +0.05f} },

	/* Workspaces 1..9 */
	TAGKEYS(                     XKB_KEY_1,          XKB_KEY_exclam,      0),
	TAGKEYS(                     XKB_KEY_2,          XKB_KEY_at,          1),
	TAGKEYS(                     XKB_KEY_3,          XKB_KEY_numbersign,  2),
	TAGKEYS(                     XKB_KEY_4,          XKB_KEY_dollar,      3),
	TAGKEYS(                     XKB_KEY_5,          XKB_KEY_percent,     4),
	TAGKEYS(                     XKB_KEY_6,          XKB_KEY_asciicircum, 5),
	TAGKEYS(                     XKB_KEY_7,          XKB_KEY_ampersand,   6),
	TAGKEYS(                     XKB_KEY_8,          XKB_KEY_asterisk,    7),
	TAGKEYS(                     XKB_KEY_9,          XKB_KEY_parenleft,   8),

	/* Virtual Terminal (TTY) Switching (Ctrl+Alt+F1..F12) */
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),

	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Q,          quit,           {0} },
};

/* Mouse Buttons */
static const Button buttons[] = {
	{ ClkLtSymbol, 0,      BTN_LEFT,   setlayout,      {.v = &layouts[0]} },
	{ ClkLtSymbol, 0,      BTN_RIGHT,  setlayout,      {.v = &layouts[2]} },
	{ ClkTitle,    0,      BTN_MIDDLE, zoom,           {0} },
	{ ClkStatus,   0,      BTN_MIDDLE, spawn,          {.v = termcmd} },
	{ ClkClient,   MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ ClkClient,   MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ ClkClient,   MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
	{ ClkTagBar,   0,      BTN_LEFT,   view,           {0} },
	{ ClkTagBar,   0,      BTN_RIGHT,  toggleview,     {0} },
	{ ClkTagBar,   MODKEY, BTN_LEFT,   tag,            {0} },
	{ ClkTagBar,   MODKEY, BTN_RIGHT,  toggletag,      {0} },
};
