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
const byte screen_width = 20;
const byte screen_height = 4;
const boolean debugging = false;

byte buffer[buffer_size];
int cursor_pos = 0;
int buffer_used = 0;

byte backlight = 128; 

void update_buffer(byte c, byte e)
{
  //check for control chars
  if(e & 1) //control key
  {
    if(c == 129) //up key
    {
      if(backlight < 157)
      {
        backlight++;
        lcdSerial.print(124, BYTE);
        lcdSerial.print(backlight, BYTE);
        delay(100);
      }
    }
    if(c == 130) //down key
    {
      if(backlight > 128)
      {
        backlight--;
        lcdSerial.print(124, BYTE);
        lcdSerial.print(backlight, BYTE);
        delay(100);
      }
    }
    return;
  }
  
  //white-list of printable chars and enter
  if(c >= 32 && c <= 122 || c == 10)
  {
    //protect against overflow
    if(buffer_used < screen_width)
    {
      //r-shift all chars after cursor
      for(int i = buffer_used; i >= cursor_pos; i--)
      {
        buffer[i+1] = buffer[i];
      }
      
      //insert character in position
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
  int row = 0;
  
  //clear lcd, set cursor to start
  lcdSerial.print(254, BYTE);
  lcdSerial.print(1, BYTE);

  //only print what is in the buffer
  for(int i = 0; i < buffer_used; i++)
  {
    //if newline, move down a line
    if(buffer[i] == 10)
    {
      if(row >= 0 && row < 3)
      {
        lcdSerial.print(254, BYTE);
        switch(row)
        {
          case 0:
            lcdSerial.print(192, BYTE);
            break;
          case 1:
            lcdSerial.print(148, BYTE);
            break;
          case 2:
            lcdSerial.print(212, BYTE);
            break;
        }
        row++;
      }
    }

    //if printable, print
    if(buffer[i] >= 32 && buffer[i] <= 122)
    {
      lcdSerial.print(buffer[i], BYTE);
    }
  }
  
  /*
    set the cursor - the "cursor_pos" is from the start of 
    the buffer, the actually displayed cursor needs adjusting
    for the row etc.
  */
//  delay(100);
//  lcdSerial.print(254, BYTE);
//  lcdSerial.print(128 + cursor_pos, BYTE);
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
  lcdSerial.print(backlight, BYTE);

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
  lcdSerial.print("Press key to start..");
}

void loop()
{
  if(keyboard.available())
  {
    if(debugging)
    {
      //debug loop
      byte c = keyboard.read();
      lcdSerial.print(254, BYTE);
      lcdSerial.print(1, BYTE);
      lcdSerial.print(c, DEC);
    }
    else
    {
      //standard loop
      byte e = keyboard.read_extra();
      byte c = keyboard.read();
      update_buffer(c, e);
      print_buffer();
    }
  }
}
