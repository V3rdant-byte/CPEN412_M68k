
void main(void)
{
    // address input
    // word and long input should be aligned to even addresses
    unsigned int start;
    unsigned int end;

    do{
        printf("\r\nstart Address (min 0x08000000 max 0x0803FFFF): ");
        start = Get8HexDigits(0);
    } while (0x08000000 > start || 0x0803FFFF < start);
    do{
        printf("\r\nend Address (min 0x08000000 max 0x0803FFFF): ");
        end = Get8HexDigits(0);
    } while (start > end || end > 0x0803FFFF);

    // test data pattern
    char input_char;
    unsigned long int data;
    unsigned long int write_data;
    while(1){
        FlushKeyboard();
        printf("\r\nChoose test pattern: \r\na: 55\r\nb: AA\r\nc: FF\r\nd: 00");
        printf("\r\n#");
        input_char = toupper(_getch());

        if(input_char == (char)('a')){                 
            data = 0x55;
            printf("\r\nData selected: 0x%x", data);
            break;
        }
        else if(input_char == (char)('b')){
            data = 0xAA;
            printf("\r\nData selected: 0x%x", data);
            break;
        }
        else if(input_char == (char)('c')){
            data = 0xFF;
            printf("\r\nData selected: 0x%x", data);
            break;
        }
        else if(input_char == (char)('d')){
            data = 0x00;
            printf("\r\nData selected: 0x%x", data);
            break;
        }
    }

    // test data size selection
    while(1)    {
        FlushKeyboard();
        printf("\r\nEnter 'B', 'W', or 'L' for bytes, words, or long words: ");
        printf("\r\n#");
        input_char = toupper(_getch());

        if(input_char == 'B'){
            printf("\r\nLong word");
            break;
        }
        else if(input_char == 'W'){
            printf("\r\nWord");
            data = data | data << 8;
            break;
        }
        else if(input_char == 'L'){
            printf("\r\nBytes");
            data = data | data << 8 | data << 16 | data << 24;
            break;
        }   
    }
	
    // start writing
    unsigned long long int *ramptr;
    // unsigned int counter = 0x900;
    ramptr = start;
    while(1){
        if (ramptr > end){
            printf("\r\nWrite complete. starting read.");
            break;
        }
        *ramptr = data;
        
        // counter++;
        // Dont check every time, just check some time incl first time
        // if (counter == 0x901){
        //     printf("\r\nWrite: 0x%x to addr 0x%x", *ramptr, ramptr);
        //     counter = 1;
        // }
        // Increment address
        ramptr++;
    }
    
    // start reading
    ramptr = start;
    // Reset counter to default
    // counter = 0x900;

    // Read loop
    while(1){
        // When end addr is reached
        if (ramptr > end){
            printf("\r\nRead complete.");
            printf("\r\nPASS: Mem test completed with no errors.");
            break;
        }
        // Read check every address to specified data by user
        if (*ramptr != data){
            printf("\r\nERROR: Address 0x%x data is 0x%x but should be 0x%x", ramptr, *ramptr, data);
            printf("\r\nFAIL: Mem test did not complete successfully.");
            break;
        }
        // counter++;
        // // Dont check every time, just check some time incl first time
        // if (counter == 0x8cc){
        //     printf("\r\nRead: Address 0x%x data is 0x%x", ramptr, *ramptr);
        //     counter = 1;
        // }
        ramptr++;
    }
}   