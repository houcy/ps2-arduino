#include <AFSoftSerial.h>
#include "PS2Keyboard.h"

#define KBD_CLK_PIN  3
#define KBD_DATA_PIN 4
#define is_printable(c) (!(c&0x80))

AFSoftSerial lcdSerial =  AFSoftSerial(9, 10);
PS2Keyboard keyboard;

const byte buffer_max = 5;
byte buffer[buffer_max];
byte buffer_pos = 0;

void update_buffer(byte c)
{
  if(c >= 32 && c <= 126) //white-list of printable chars
  {
    //protect agains overflow
    if(buffer_pos < buffer_max)
    {
      //add text to buffer
      buffer[buffer_pos] = c;
      buffer_pos++;
    }
  }
  else
  {
    if(c == 128) //backspace
    {
      if(buffer_pos > 0)
      {
        buffer_pos--;
      }
    }
  }
}

void print_buffer()
{
  //clear lcd, set cursor to start
  lcdSerial.print(254,BYTE);
  lcdSerial.print(1,BYTE);

  //print buffer
  for(int i=0; i < buffer_pos; i++)
  {
    lcdSerial.print(buffer[i], BYTE);
  }
}

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
  
  //signal ready
  digitalWrite(13, 1);
}

void loop()
{
  if(keyboard.available())
  {
    byte c = keyboard.read();
    update_buffer(c);
    print_buffer();
  }
}
