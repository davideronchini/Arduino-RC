/*
 * __________________________
 * |                        |
 * |   BLUETOOTH MODULE     |
 * |________________________|
 * 
 */
#include <SoftwareSerial.h>

char state = 'O';
int pinRx = 3;
int pinTx = 2;

int pinEngineDx = 9;
int pinEngineSx = 6;

SoftwareSerial BTserial(pinRx, pinTx);

/*
 * __________________________
 * |                        |
 * |       DHT SENSOR       |
 * |________________________|
 * 
 */

/* DISABLED
#include <dht_nonblocking.h>
#define DHT_SENSOR_TYPE DHT_TYPE_11

static const int DHT_SENSOR_PIN = 7;
DHT_nonblocking dht_sensor( DHT_SENSOR_PIN, DHT_SENSOR_TYPE );
*/
bool isAvailable = false;

void setup() {
    // Inizializza i pin dei due motori
    pinMode(pinEngineDx, OUTPUT);
    pinMode(pinEngineSx, OUTPUT);

    // I motori sono inizialmente spenti
    digitalWrite(pinEngineDx,LOW);
    digitalWrite(pinEngineSx,LOW);
      
    Serial.begin(9600);    // Initialize serial communication
    BTserial.begin(9600);  // HC-06 default serial speed is 9600
}

/*
 * Poll for a measurement, keeping the state machine alive.  Returns
 * true if a measurement is available.
 */
 
 /* DISABLED
static bool measure_environment( float *temperature, float *humidity )
{
  static unsigned long measurement_timestamp = millis( );

  // Measure once every four seconds.
  if( millis( ) - measurement_timestamp > 3000ul )
  {
    if( dht_sensor.measure( temperature, humidity ) == true )
    {
      measurement_timestamp = millis( );
      return( true );
    }
  }

  return( false );
}
*/

void loop() {
    /* DISABLED
    float temperature;
    float humidity;

    // Measure temperature and humidity.  If the functions returns
    //true, then a measurement is available.
    if( measure_environment( &temperature, &humidity ) == true ){
      isAvailable = true;
    }else {
     //Serial.println("Error");
    }
    */
  
    if(BTserial.available() > 0){
     state = BTserial.read();  
     //Serial.println(state);
    }
    
    // Per lo spostamento utilizza i tasti wasd e i tasti qe
    switch (state){
      case 'w':
        analogWrite(pinEngineDx, 200);
        analogWrite(pinEngineSx, 255);
        break;
      case 'q':
        analogWrite(pinEngineDx, 165); // il motore destro gira più del sinistro
        analogWrite(pinEngineSx, 180);
        break;
      case 'e':
        analogWrite(pinEngineDx, 127);
        analogWrite(pinEngineSx, 255);
        break;
      case 's':
        analogWrite(pinEngineDx, 0);
        analogWrite(pinEngineSx, 0);
        break;
      case 'a':
        analogWrite(pinEngineDx, 255);
        analogWrite(pinEngineSx, 0);
        break;
      case 'd':
        analogWrite(pinEngineDx, 0);
        analogWrite(pinEngineSx, 255);
        break;
      case 't':
        if (isAvailable == true){
          /* DISABLED BTserial.print(temperature, 1); */
          //Serial.print( "°C, ");
          //Serial.print( humidity, 1 );
          //Serial.println( "%" );
        }else{
          //BTserial.print("Not Available");
        }
        break;

      default:
        break;
    }

    state = '0';
} 
