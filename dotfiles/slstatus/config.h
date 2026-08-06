/* slstatus config.h - Artix Suckless Workstation Status Bar Config
 * Version: 2.1 (RAM in MB/Total, Network Name/State, CPU, SSD, Date/Time)
 */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 256

static const struct arg args[] = {
	/* function     format                   argument */
	{ ram_used,     " [RAM %s/",             NULL },
	{ ram_total,    "%s]",                   NULL },
	{ cpu_perc,     " [CPU %s%%]",           NULL },
	{ run_command,  " [NET %s]",             "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 || ip route get 1 2>/dev/null | awk '{print $5}' || echo 'Offline'" },
	{ disk_perc,    " [SSD %s%%]",           "/" },
	{ datetime,     " | %s",                 "%Y-%m-%d %H:%M:%S" },
};
