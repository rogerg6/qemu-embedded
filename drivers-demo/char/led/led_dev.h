#ifndef _BOARD_RESOURCE_H
#define _BOARD_RESOURCE_H

/**
 * GPIO group3, pin4用一个32位整数来表示
 * bit[31:16] for group
 * bit[15:0]  for pin
 */
#define GROUP_PIN(g, p) ((g << 16) | p)
#define GROUP(x) (x >> 16)
#define PIN(x) (x & 0xffff)



#endif