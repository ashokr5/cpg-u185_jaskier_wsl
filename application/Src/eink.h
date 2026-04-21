/*
 * eink.h
 *
 *  Created on: 25-Jul-2025
 *      Author: rashok
 */

#ifndef EINK_H_

//#define EPD_GD_2_13
//#define EPD_GD_0_97
#define EPD_GD_1_54

#if defined EPD_GD_2_13

#define EPD_GD_2_13_WIDTH           128u
#define EPD_GD_2_13_HEIGHT          250u

#define EPD_GD_OFFSET               44 //44

#define EPD_GD_BYTES_SIZE           (EPD_GD_2_13_WIDTH*EPD_GD_2_13_HEIGHT) /8u //4000

#define EPD_GD_RBUFFER_SIZE         EPD_GD_2_13_WIDTH / 8
#define EPD_GD_RBUFFER_LAST         EPD_GD_RBUFFER_SIZE
#define EPD_GD_RBUFFER_LEN          EPD_GD_2_13_HEIGHT -1

#define EPD_GD_WIDTH                EPD_GD_2_13_WIDTH
#define EPD_GD_HEIGHT               EPD_GD_2_13_HEIGHT

#define EPD_GD_INVERT               1
#define EPD_GD_MIRROR               1
#endif 

#if defined EPD_GD_1_54

#define EPD_GD_1_54_WIDTH           200u
#define EPD_GD_1_54_HEIGHT          200u

#define EPD_GD_OFFSET               0 //44

#define EPD_GD_BYTES_SIZE           (EPD_GD_1_54_WIDTH*EPD_GD_1_54_HEIGHT) /8u //5000

#define EPD_GD_RBUFFER_SIZE         EPD_GD_1_54_WIDTH / 8
#define EPD_GD_RBUFFER_LAST         EPD_GD_RBUFFER_SIZE
#define EPD_GD_RBUFFER_LEN          EPD_GD_1_54_HEIGHT -1

#define EPD_GD_WIDTH                EPD_GD_1_54_WIDTH
#define EPD_GD_HEIGHT               EPD_GD_1_54_HEIGHT

#define EPD_GD_INVERT               1
#define EPD_GD_MIRROR               1
#endif


#if defined EPD_GD_0_97

#define EPD_GD_0_97_WIDTH           88u
#define EPD_GD_0_97_HEIGHT          184u

#define EPD_GD_OFFSET               0//0u //44

#define EPD_GD_BYTES_SIZE           (EPD_GD_0_97_WIDTH*EPD_GD_0_97_HEIGHT) /8u //2024

#define EPD_GD_RBUFFER_SIZE         EPD_GD_0_97_WIDTH / 8
#define EPD_GD_RBUFFER_LAST         EPD_GD_RBUFFER_SIZE
#define EPD_GD_RBUFFER_LEN          EPD_GD_0_97_HEIGHT -1

#define EPD_GD_WIDTH                EPD_GD_0_97_WIDTH
#define EPD_GD_HEIGHT               EPD_GD_0_97_HEIGHT

#define EPD_GD_INVERT               1
#define EPD_GD_MIRROR               0
#endif




void eink_spi_init(void);
uint8_t eink_configure_gpio(void);
void eink_gd_hwinit_screen(void);
void eink_gd_update_bw_2_13(void);
void eink_gd_update_bw_0_97(void);
void eink_gd_update_bw_1_54(void);
/* EPD_EN pin not configured in GPIO setup */
// void eink_power_off(void);
// void eink_power_on(void);
void eink_gd_sleep(void);
void eink_gd_set_white(void);

#endif /* EINK_H_ */
