#include <AFSoftSerial.h>
#include "PS2Keyboard.h"

#define KBD_CLK_PIN  3
#define KBD_DATA_PIN 4
#define is_printable(c) (!(c&0x80))

AFSoftSerial lcdSerial =  AFSoftSerial(9, 10);
PS2Keyboard keyboard;

void setup()
{
  delay(5000);
  lcdSerial.begin(9600);
  
  //set backlight to low
  lcdSerial.print(124,BYTE);
  lcdSerial.print(128,BYTE);
  
  //clear lcd, set cursor to start
  lcdSerial.print(254,BYTE);
  lcdSerial.print(1,BYTE);
  
  //prep kbrd
  keyboard.begin(KBD_DATA_PIN);
}

void loop()
{
  if(keyboard.available())
  {
    byte c = keyboard.read();
    if(is_printable(c))
    {
      lcdSerial.print(c, BYTE);
    }
  }
}
