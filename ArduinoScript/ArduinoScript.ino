int HRmonitor = A3;    // select the input pin for the photoplethysmograph
int i = 0;  // variable to store the value coming from the sensor
int LED3 = 3;   //  The on-board LED
int UpperThreshold = 550;            // Determines which signals to count as a beat and which to ignore
int LowerThreshold = 490;
int reading = 0;
float BPM = 0.0;
bool IgnoreReading = false;
bool FirstPulseDetected = false;
unsigned long FirstPulseTime = 0;
unsigned long SecondPulseTime = 0;
unsigned long PulseInterval = 0;
int count=0;

void setup() {
pinMode(LED3,OUTPUT); 
Serial.begin(9600);
}

void loop() 
{
//while(count<5)
      {
  i = analogRead(HRmonitor);// Reads the value from the sensor
  Serial.print(i);
  {
  if(i > UpperThreshold){                          // If the signal is above the upper threshold the LED will blink indicating a heartbeat.
      digitalWrite(LED3,HIGH); 
      count=count+1;
      
    } 
    else {
      digitalWrite(LED3,LOW);

    }
    delay(10);
  }
  delay(10);


        
  if(i > UpperThreshold && IgnoreReading == false)// Heart beat leading edge detected.
  { 
          if(FirstPulseDetected == false){
            FirstPulseTime = millis();
            FirstPulseDetected = true;
          }
          else{
            SecondPulseTime = millis();
            PulseInterval = SecondPulseTime - FirstPulseTime;
            FirstPulseTime = SecondPulseTime;
          }
          IgnoreReading = true;
      }

        
  if(i < LowerThreshold)// Heart beat trailing edge detected.
  {
          IgnoreReading = false;
        }  

        BPM = (1.0/PulseInterval) * 60.0 * 1000;

        delay(10);
        Serial.print("a");
        Serial.flush(); 
  
  }

}
