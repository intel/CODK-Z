#include <zephyr.h>

void main (void)
{
	while(1)
	{
		task_yield();
	}
}
