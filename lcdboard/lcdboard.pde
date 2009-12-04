#include <AFSoftSerial.h>
#include "PS2Keyboard.h"

#define KBD_CLK_PIN  3
#define KBD_DATA_PIN 4
#define is_printable(c) (!(c&0x80))

AFSoftSerial lcdSerial =  AFSoftSerial(9, 10);
PS2Keyboard keyboard;

const int buffer_size = 25;
byte buffer[buffer_size];
int buffer_pos = 0;

int row = 0;

void update_buffer(byte c)
{
  if(c >= 32 && c <= 122) //white-list of printable chars
  {
    //protect against overflow
    if(buffer_pos < buffer_size)
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
  lcdSerial.print(254, BYTE);
  lcdSerial.print(1, BYTE);

  //print only the current line.
  int r = 0;  
  for(int i=0; i < buffer_pos; i++)
  {
    /*
      scroll down to the row (line) you want, each time you hit a newline char
      you have started a new row.
    */
    if(buffer[i] == '\n')
    {
      r++;
    }
    if(r == row)
    {
      lcdSerial.print(buffer[i], BYTE);
    }
  }
}

void setup()
{
  //turn lcd on
  digitalWrite(12, 1);

  delay(5000);
  
  //prep serial
  lcdSerial.begin(9600);
  
  //set backlight to low
  lcdSerial.print(124, BYTE);
  lcdSerial.print(128, BYTE);
  
  //set lcd type to 20x4
//  lcdSerial.print(124, BYTE);
//  lcdSerial.print(3, BYTE);
//  lcdSerial.print(124, BYTE);
//  lcdSerial.print(5, BYTE);
    
  //clear lcd, set cursor to start
  lcdSerial.print(254, BYTE);
  lcdSerial.print(1, BYTE);
  
  //prep kbrd
  keyboard.begin(KBD_DATA_PIN);
  
  //signal ready
  digitalWrite(13, 1);

  //test code
//  byte a = byte(65);
//  update_buffer(a);
//  print_buffer();
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
