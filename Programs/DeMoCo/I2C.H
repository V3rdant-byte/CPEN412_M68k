
//////////////////////////////
// I2C Controller Registers //
//////////////////////////////
#define I2C_CLK_PRESCALE_LOW (*(volatile unsigned char *)(0x00408000))
#define I2C_CLK_PRESCALE_HIGH (*(volatile unsigned char *)(0x00408002))
#define I2C_CTRL (*(volatile unsigned char *)(0x00408004))
#define I2C_TX (*(volatile unsigned char *)(0x00408006))
#define I2C_RX (*(volatile unsigned char *)(0x00408006))
#define I2C_CMD (*(volatile unsigned char *)(0x00408008))
#define I2C_STAT (*(volatile unsigned char *)(0x00408008))

//////////////////
// I2C Commands //
//////////////////
#define I2C_CMD_Slave_Write_With_Start 0x91 // 1001 0001
#define I2C_CMD_Slave_Read_With_Start 0xA9  // 1010 1001
#define I2C_CMD_Slave_Write 0x11            // 0001 0001
#define I2C_CMD_Slave_Read 0x21             // 0010 0001
#define I2C_CMD_Slave_Read_Ack 0x29         // 0010 1001
#define I2C_CMD_Slave_Write_Stop 0x51       // 0101 0001
#define I2C_CMD_Slave_Read_Stop 0x49        // 0100 1001

/////////////////////
// EEPROM Commands //
/////////////////////
#define EEPROM_Write_Block_1 0xA2           // 1010 0010
#define EEPROM_Read_Block_1 0xA3            // 1010 0011
#define EEPROM_Write_Block_0 0xA0           // 1010 0000
#define EEPROM_Read_Block_0 0xA1            // 1010 0001

//////////////////////
// ADC/DAC Commands //
//////////////////////
#define ADC_DAC_Write_Address 0x90          // 1001 0000
#define ADC_Read_Address 0x91               // 1001 0001
#define ADC_CMD_Enable 0x44                 // 0100 0100
#define DAC_CMD_Enable 0x40                 // 0100 0000

#define Enable_I2C_Controller() I2C_CTRL = 0x80     // 1000 0000


// I2C prototypes
void I2C_Init(void);
void WriteI2CInteraction(int block, unsigned int Address, unsigned char AddressMSB, unsigned char AddressLSB, unsigned char data, int flag);
void PageWriteI2CInteraction(unsigned int AddressFrom, unsigned int AddressTo, unsigned char data);
void ReadI2CByteInteraction(int block, unsigned int Address, unsigned char AddressMSB, unsigned char AddressLSB);
void ReadI2CSequential(int block, int AddressTo, int AddressFrom,  unsigned int ChipAddress);
void DACWrite(void);
char ADCRead(int);
void WriteI2C(void);
void ReadI2C(void);
void PageWriteI2C(void);
void SeqReadI2C(void);