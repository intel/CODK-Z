#include <zephyr.h>

/* Stack size used by the main thread */
#define STACKSIZE   2048

/* Scheduling priority used by the main thread */
#define PRIORITY    7

void main (void)
{
	while(1)
	{
		k_yield();
	}
}

K_THREAD_DEFINE(main_id, STACKSIZE, main, NULL, NULL, NULL,
		PRIORITY, 0, K_NO_WAIT);
