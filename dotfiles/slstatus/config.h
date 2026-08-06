/* slstatus config.h - Artix Suckless Workstation Status Bar Config
 * Version: 1.0
 * Native C modules, minimal update interval polling to preserve CPU.
 */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 256

static const struct arg args[] = {
	/* function     format               argument */
	{ ram_perc,     " [RAM %s%%]",       NULL },
	{ cpu_perc,     " [CPU %s%%]",       NULL },
	{ disk_perc,    " [SSD %s%%]",       "/" },
	{ datetime,     " | %s",             "%Y-%m-%d %H:%M:%S" },
};
