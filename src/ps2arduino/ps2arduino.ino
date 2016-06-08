/*
  Target Diecimila + ATmega168 
*/
#include "PS2Keyboard.h"

#define CLOCK_PIN 3
#define DATA_PIN 4

PS2Keyboard keyboard;
char c;

void setup()
{
  Serial.begin(9600); 
  Serial.println("setup()");
  
  delay(1000);
  keyboard.begin(DATA_PIN, CLOCK_PIN);
}

void loop()
{
  Serial.println("loop()");
  if(keyboard.available())
  {
    Serial.println("keyboard.available()");

    c = keyboard.read();

    Serial.println("char!");

    Serial.println(c);
  }
}

