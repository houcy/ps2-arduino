#include <AFSoftSerial.h>

AFSoftSerial lcdSerial =  AFSoftSerial(9, 10);

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
}

void loop()
{
  digitalWrite(13,HIGH);
  delay(1000);
  digitalWrite(13,LOW);
  lcdSerial.print("hello world");
  delay(1000);
}
