/*
  Target Diecimila + ATmega168 
*/
#include "PS2Keyboard.h"

#define KBD_CLK_PIN 3
#define KBD_DATA_PIN 4

PS2Keyboard keyboard;

void setup()
{
  Serial.begin(9600); 
  Serial.print("setup()");
  
  delay(1000);
  keyboard.begin(KBD_DATA_PIN);
}

void loop()
{
  if(keyboard.available())
  {
    byte e = keyboard.read_extra();
    byte c = keyboard.read();
  }
}

