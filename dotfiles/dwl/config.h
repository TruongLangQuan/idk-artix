/* dwl config.h - Artix Suckless Workstation
 * Version: 1.1
 * Pure Monochrome Aesthetics & Keyboard-driven Workflow
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
static const float rootcolor[]             = COLOR(0x000000ff);
static const float bordercolor[]           = COLOR(0x333333ff);
static const float focuscolor[]            = COLOR(0x808080ff);
static const float urgentcolor[]           = COLOR(0xffffffff);
static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f};

/* Tagging - Exactly 5 workspaces */
#define TAGCOUNT (5)

/* Logging */
static int log_level = WLR_ERROR;

/* Rules */
static const Rule rules[] = {
	/* app_id     title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       0,            1,           -1 },
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

static const Key keys[] = {
	/* modifier                  key                 function        argument */
	{ MODKEY,                    XKB_KEY_space,      spawn,          {.v = menucmd} },
	{ MODKEY,                    XKB_KEY_t,          spawn,          {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_b,          spawn,          {.v = browsercmd} },
	{ MODKEY,                    XKB_KEY_q,          killclient,     {0} },
	{ MODKEY,                    XKB_KEY_l,          spawn,          {.v = lockcmd} },
	{ MODKEY,                    XKB_KEY_v,          spawn,          {.v = clipcmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,      togglefloating, {0} },
	{ MODKEY,                    XKB_KEY_e,          togglefullscreen,{0} },
	{ 0,                         XKB_KEY_Print,      spawn,          {.v = shotcmd} },

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

	/* Workspaces 1..5 */
	TAGKEYS(                     XKB_KEY_1,          XKB_KEY_exclam,  0),
	TAGKEYS(                     XKB_KEY_2,          XKB_KEY_at,      1),
	TAGKEYS(                     XKB_KEY_3,          XKB_KEY_numbersign, 2),
	TAGKEYS(                     XKB_KEY_4,          XKB_KEY_dollar,  3),
	TAGKEYS(                     XKB_KEY_5,          XKB_KEY_percent, 4),

	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Q,          quit,           {0} },
};

/* Mouse Buttons */
static const Button buttons[] = {
	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ MODKEY, BTN_MIDDLE, togglefloating, {0} },
	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
