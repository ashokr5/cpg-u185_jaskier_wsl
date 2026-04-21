#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "main.h"
#include "eink.h"
#include "images.h"

/* E-Ink GPIO Pin Definitions - Matched with main.h configuration */
/* These match the IOC/CubeMX configuration in main.h */
#define EPD_CS_PORT     GPIOB
#define EPD_CS_PIN      GPIO_PIN_0

#define EPD_DC_PORT     GPIOC
#define EPD_DC_PIN      GPIO_PIN_7

#define EPD_RST_PORT    GPIOA
#define EPD_RST_PIN     GPIO_PIN_9

#define EPD_BSY_PORT    GPIOA
#define EPD_BSY_PIN     GPIO_PIN_10

/* SPI Instance - using SPI1 by default */
extern SPI_HandleTypeDef hspi1;

/* GPIO Control Macros */
#define EPD_cs_low()    HAL_GPIO_WritePin(EPD_CS_PORT, EPD_CS_PIN, GPIO_PIN_RESET)
#define EPD_cs_high()   HAL_GPIO_WritePin(EPD_CS_PORT, EPD_CS_PIN, GPIO_PIN_SET)

#define EPD_dc_low()    HAL_GPIO_WritePin(EPD_DC_PORT, EPD_DC_PIN, GPIO_PIN_RESET)
#define EPD_dc_high()   HAL_GPIO_WritePin(EPD_DC_PORT, EPD_DC_PIN, GPIO_PIN_SET)

#define EPD_rst_low()   HAL_GPIO_WritePin(EPD_RST_PORT, EPD_RST_PIN, GPIO_PIN_RESET)
#define EPD_rst_high()  HAL_GPIO_WritePin(EPD_RST_PORT, EPD_RST_PIN, GPIO_PIN_SET)

#define EPD_delay_ms(X) HAL_Delay(X)

extern volatile int lock_status;


//const uint8_t dummy_white[EPD_GD_BYTES_SIZE]={0xff};
//const uint8_t dummy[EPD_GD_BYTES_SIZE]={0x00};

/**
  * @brief Transmit a single byte via SPI
  * @param data: byte to transmit
  */
static void spi_sendbyte(uint8_t data)
{
	uint8_t txData = data;
	HAL_SPI_Transmit(&hspi1, &txData, 1, HAL_MAX_DELAY);
}

/**
  * @brief Transmit multiple bytes via SPI
  * @param data: pointer to data buffer
  * @param len: number of bytes to transmit
  */
static void spi_sendbytes(uint8_t *data, uint32_t len)
{
	HAL_SPI_Transmit(&hspi1, data, len, HAL_MAX_DELAY);
}

static void sendCmd( uint8_t cmd) {

  EPD_cs_low();
  EPD_dc_low();
 // k_sleep(K_USEC(10));
  spi_sendbyte(cmd);
 // k_sleep(K_USEC(10));
  EPD_cs_high();
  //EPD_dc_high();

}

static void sendData( uint8_t data) {

  EPD_cs_low();
  EPD_dc_high();
 // k_sleep(K_USEC(10));
  spi_sendbyte(data);
 // k_sleep(K_USEC(10));
  EPD_cs_high();
  //EPD_dc_low();

}

static void sendDatabytes(uint8_t *data, uint32_t len) {

  EPD_cs_low();
  EPD_dc_high();
 // k_sleep(K_USEC(10));
  spi_sendbytes(data,len);
 // k_sleep(K_USEC(10));
  EPD_cs_high();
 // EPD_dc_low();

}

void eink_spi_init(void)
{
	/* SPI is already initialized by HAL in main.c/stm32f4xx_hal_msp.c */
	/* Just verify SPI is ready */
	if (hspi1.State != HAL_SPI_STATE_READY) {
	//	printf("SPI1 initialization failed!\r\n");
	}
	//else {
	//	printf("SPI1 initialized successfully\r\n");
	//}
}

void epd_wait(void)
{
	printf("epd wait start.. status=%d\r\n", HAL_GPIO_ReadPin(EPD_BSY_PORT, EPD_BSY_PIN));
	while (HAL_GPIO_ReadPin(EPD_BSY_PORT, EPD_BSY_PIN) != GPIO_PIN_RESET) {
		/* Spin until BUSY goes low */
		EPD_delay_ms(1);
	}
	//printf("epd wait over. status=%d\r\n", HAL_GPIO_ReadPin(EPD_BSY_PORT, EPD_BSY_PIN));
}

void epd_gd_soft_reset(void)
{
	sendCmd(0x12);   //Soft-reset
}

void epd_gd_sleep(void)
{
	sendCmd(0x10);
	sendData(0x01);    //Sleep
}

void epd_gd_set_temp()
{
	sendCmd(0x18);
	sendData(0x80);    //temp

	sendCmd(0x22);
	sendData(0xb1);    //temp
	sendCmd(0x20);

	epd_wait();

	sendCmd(0x1a);
	sendData(0x64); 
	sendData(0x00); 

	sendCmd(0x22);
	sendData(0x91); 
	sendCmd(0x20);

	epd_wait();
   // printf("epd set temp done\r\n");
}

void epd_gd_read_temp()
{

	sendCmd(0x18);
	sendData(0x80); 

   // printf("epd read temp done\r\n");
}

void epd_gd_set_doc()
{

	sendCmd(0x01); //Driver output control     
	sendData((EPD_GD_HEIGHT+EPD_GD_OFFSET-1)%256); 
	sendData((EPD_GD_HEIGHT+EPD_GD_OFFSET-1)/256); 
	sendData(EPD_GD_MIRROR); // 0x01 - mirror

	sendCmd(0x11);
	sendData(0x01);  //data entry mode 

   // printf("epd set doc done\r\n");
}

void epd_gd_set_duc()
{
	uint8_t temp[2] = {0x00, 0x80};

	sendCmd(0x21);
	sendData(0x00); 
	sendData(0x80); //Display update control 

   // printf("epd set duc done\r\n");
}

void epd_gd_set_pos()
{
	sendCmd(0x44);
	sendData(0x00); 
	sendData((EPD_GD_WIDTH/8)-1); //Set ram x start/end pos    

	sendCmd(0x45);
	sendData((EPD_GD_HEIGHT+EPD_GD_OFFSET-1)%256); 
	sendData((EPD_GD_HEIGHT+EPD_GD_OFFSET-1)/256); //Set ram y start/end pos    
	sendData(0x00); 
	sendData(0x00); 

	sendCmd(0x3c);
	sendData(0x05); //BorderWaveform
	//sendData(0x80); //Set borderwave

   // printf("epd set pos done\r\n");
}

void epd_gd_set_pos2()
{
	sendCmd(0x4E);
	sendData(0x00); //Set ram x count to 0   

	sendCmd(0x4F);
	sendData((EPD_GD_HEIGHT+EPD_GD_OFFSET -1)%256); //Set ram x count to 128   
	sendData((EPD_GD_HEIGHT+EPD_GD_OFFSET -1)/256); 

   // printf("epd set pos2 done\r\n");
}

//Full screen refresh display function
void eink_gd_update_bw_2_13(void)
{

	sendCmd(0x24);
	sendDatabytes(gImage_gd_id_name_tag_bw1_2_13,EPD_GD_BYTES_SIZE);
	//sendDatabytes(gImage_gd_white_2_13,EPD_GD_BYTES_SIZE);
	sendCmd(0x18);
	sendData(0xff);

	sendCmd(0x22);
	sendData(0xf7);	//Display Update Control
	sendCmd(0x20);	//Activate Display Update Sequence

	epd_wait();
}

//Full screen refresh display function
void eink_gd_update_bw_1_54(void)
{

	sendCmd(0x24);
	sendDatabytes(gImage_gd_p1_1_54,EPD_GD_BYTES_SIZE);
	//sendDatabytes(gImage_gd_white_2_13,EPD_GD_BYTES_SIZE);
	sendCmd(0x18);
	sendData(0xff);

	sendCmd(0x22);
	sendData(0xf7);	//Display Update Control
	sendCmd(0x20);	//Activate Display Update Sequence

	epd_wait();
}

//Full screen refresh display function
void eink_gd_init_bw_0_97(void)
{

	sendCmd(0x24);

	sendDatabytes(gImage_gd_elock_bw_flash_0_97,EPD_GD_BYTES_SIZE);
	sendCmd(0x18);
	sendData(0xff);

	sendCmd(0x22);
	sendData(0xf7);	//Display Update Control
	sendCmd(0x20);//Activate Display Update Sequence

	epd_wait();
}

//Full screen refresh display function
void eink_gd_update_bw_0_97(void)
{

	sendCmd(0x24);

	if(lock_status)
	{
		sendDatabytes(gImage_gd_elock_bw_locked_0_97,EPD_GD_BYTES_SIZE);
	}
	else
	{
		sendDatabytes(gImage_gd_elock_bw_unlocked_0_97,EPD_GD_BYTES_SIZE);
		
	}

	sendCmd(0x18);
	sendData(0xff);
	sendCmd(0x22);
	sendData(0xf7);	//Display Update Control
	sendCmd(0x20);	//Activate Display Update Sequence

	epd_wait();
}


void eink_gd_set_white(void)
{

	sendCmd(0x24);
	sendDatabytes(gImage_gd_white_2_13,EPD_GD_BYTES_SIZE);

	sendCmd(0x22);
	sendData(0xf7);	//Display Update Control
	sendCmd(0x20);	//Activate Display Update Sequence

	epd_wait();
}


void eink_gd_hwinit_screen(void)
{
	EPD_rst_low();
	EPD_delay_ms(10);
	EPD_rst_high();
	EPD_delay_ms(10);

	epd_wait();

	epd_gd_soft_reset();  //soft reset

	epd_wait();

	epd_gd_set_doc();

	epd_gd_set_pos();

	epd_gd_set_duc();

	//epd_gd_set_temp();
	epd_gd_read_temp();

	epd_gd_set_pos2();

	epd_wait();

	//printf("EPD init done\r\n");

}


void eink_gd_fast_hwinit_screen(void)
{

	EPD_rst_low();
	EPD_delay_ms(10);
	EPD_rst_high();
	EPD_delay_ms(20);

	epd_wait();

	epd_gd_soft_reset();

	epd_wait();

    epd_gd_set_temp();
	
   // printf("EPD fast init done\r\n");

	//k_sem_give(&epd_init_ok);
}

/**
  * @brief Configure GPIO pins for e-ink display
  * @note GPIO ports should already be configured via CubeMX/main.c
  *       This function performs basic verification
  * @return 1 if successful, 0 if failed
  */
uint8_t eink_configure_gpio(void)
{
	/* GPIO ports are pre-configured by CubeMX in stm32f4xx_hal_msp.c */
	/* Just verify the pins are set to initial state */
	
	/* Initialize all control pins */
	HAL_GPIO_WritePin(EPD_CS_PORT, EPD_CS_PIN, GPIO_PIN_SET);
	HAL_GPIO_WritePin(EPD_DC_PORT, EPD_DC_PIN, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(EPD_RST_PORT, EPD_RST_PIN, GPIO_PIN_SET);
	
//	printf("E-Ink GPIO pins configured\r\n");
	return 1;
}

/**
  * @brief Toggle e-ink power supply
  * @note EPD_EN pin is not configured in current GPIO setup
  */
/*
void eink_power_toggle(void)
{
	HAL_GPIO_TogglePin(EPD_EN_PORT, EPD_EN_PIN);
}
*/

/**
  * @brief Turn on e-ink power supply
  * @note EPD_EN pin is not configured in current GPIO setup
  */
/*
void eink_power_on(void)
{
	HAL_GPIO_WritePin(EPD_EN_PORT, EPD_EN_PIN, GPIO_PIN_SET);
}
*/

/**
  * @brief Turn off e-ink power supply
  * @note EPD_EN pin is not configured in current GPIO setup
  */
/*
void eink_power_off(void)
{
	HAL_GPIO_WritePin(EPD_EN_PORT, EPD_EN_PIN, GPIO_PIN_RESET);
}
*/
