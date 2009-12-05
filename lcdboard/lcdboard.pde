#include <SoftwareSerial.h>
#include "PS2Keyboard.h"

#define rxPin 11
#define txPin 10

#define KBD_CLK_PIN  3
#define KBD_DATA_PIN 4
#define is_printable(c) (!(c&0x80))

SoftwareSerial lcdSerial =  SoftwareSerial(rxPin, txPin);
PS2Keyboard keyboard;

const int buffer_size = 25;
const int screen_width = 20;

byte buffer[buffer_size];
int cursor_pos = 0;
int buffer_used = 0;

int row = 0;

void update_buffer(byte c)
{
  if(c >= 32 && c <= 122) //white-list of printable chars
  {
    //protect against overflow
    if(cursor_pos < screen_width)
    {
      //r-shift all chars after cursor
      for(int i = buffer_used; i >= cursor_pos; i--)
      {
        buffer[i+1] = buffer[i];
      }
      
      //character in position
      buffer[cursor_pos] = c;
      cursor_pos++;
      buffer_used++;
    }
  }
  else
  {
    if(c == 128) //backspace
    {
      if(cursor_pos > 0)
      {
        //l-shift all chars after deleted
        for(int i = cursor_pos; i < buffer_used; i++)
        {
          buffer[i-1] = buffer[i];
        }
        buffer_used--;
        cursor_pos--;
      }
    }
    if(c == 132) //right arrow
    {
      if(cursor_pos < screen_width)
      {
        cursor_pos++;
      }
    }
    if(c == 131) //left arrow
    {
      if(cursor_pos > 0)
      {
        cursor_pos--;
      }
    }
  }
}

void print_buffer()
{
  //clear lcd, set cursor to start
  lcdSerial.print(254, BYTE);
  lcdSerial.print(1, BYTE);

  for(int i=0; i < buffer_used; i++)
  {
    if(buffer[i] == '\n')
    {
      return;
    }
    if(buffer[i] >= 32 && buffer[i] <= 122)
    {
      lcdSerial.print(buffer[i], BYTE);
    }
  }
  
  //set the cursor
  delay(100);
  lcdSerial.print(254, BYTE);
  lcdSerial.print(128 + cursor_pos, BYTE);
}

void setup()
{
  delay(1000);
  
  //prep kbrd
  keyboard.begin(KBD_DATA_PIN);
  
  //prep serial
  pinMode(rxPin, INPUT);
  pinMode(txPin, OUTPUT);
  lcdSerial.begin(9600);
  
  delay(1000);
    
  //set backlight to low
  lcdSerial.print(124, BYTE);
  lcdSerial.print(128, BYTE);

  delay(100);

  //set lcd to 20 cols
  lcdSerial.print(124, BYTE);
  lcdSerial.print(3, BYTE);
  
  delay(100);
  
  //set lcd to 4 rows
  lcdSerial.print(124, BYTE);
  lcdSerial.print(5, BYTE);
  
  delay(100);
    
  //clear lcd
  lcdSerial.print(254, BYTE);
  lcdSerial.print(1, BYTE);

  delay(100);

  //set cursor to start
  lcdSerial.print(254, BYTE);
  lcdSerial.print(0x80, BYTE);

  delay(100);
  
  //turn on underline cursor
  lcdSerial.print(254, BYTE);
  lcdSerial.print(13, BYTE);
  
  //signal ready
  digitalWrite(13, 1);

  //seems to need this...???  
  delay(500);
  
  //test code
  lcdSerial.print("Works!");
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
