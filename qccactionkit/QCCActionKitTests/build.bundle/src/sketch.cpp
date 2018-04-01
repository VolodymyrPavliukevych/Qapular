#include "Arduino.h"

void setup();
void loop();

void setup() {
      pinMode(13, OUTPUT);
}

void loop() {
    int a = 0;
    digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(100);              // wait for a second
    digitalWrite(13, LOW);    // turn the LED off by making the voltage LOW
    delay(100);              // wait for a second
    
}