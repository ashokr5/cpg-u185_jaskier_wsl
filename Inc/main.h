/**
  ******************************************************************************
  * @file    GPIO/GPIO_IOToggle/Inc/main.h 
  * @author  MCD Application Team
  * @brief   Header for main.c module
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2017 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

/* Includes ------------------------------------------------------------------*/
#include "stm32f4xx_hal.h"
#include "stm32f4xx_nucleo.h"

/* Exported types ------------------------------------------------------------*/
/* Exported constants --------------------------------------------------------*/
/* Exported macro ------------------------------------------------------------*/
/* Exported functions ------------------------------------------------------- */
/* Private defines -----------------------------------------------------------*/
#define EPD_CS_Pin GPIO_PIN_0
#define EPD_CS_GPIO_Port GPIOB
#define EPD_RST_Pin GPIO_PIN_9
#define EPD_RST_GPIO_Port GPIOA
#define EPD_DC_Pin GPIO_PIN_7
#define EPD_DC_GPIO_Port GPIOC
#define EPD_BSY_Pin GPIO_PIN_10
#define EPD_BSY_GPIO_Port GPIOA

/* Exported macro - Function declarations */
void SystemClock_Config(void);
void Error_Handler(void);
extern SPI_HandleTypeDef hspi1;
extern volatile int lock_status;

#endif /* __MAIN_H */
