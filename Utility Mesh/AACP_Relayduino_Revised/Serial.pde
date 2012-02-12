// Reads data from serial input TX in the XBee API format
int getSerialData(char s[BUF_SIZE]) {
  //Erase buffer before grabbing new data.
  memset(s,'\0',BUF_SIZE);
  char c = '\0';
  // Read serial data if there is any
  if (Serial.available()) {
    int startTime = millis ();

    //check for button presses @beginning of buffer
    readbutt();

    int i = 0;

    // waits for delimiter '~' marking start of transmission
    while (!Serial.available()) { 
    }
    s[i++] = Serial.read();

    // return if the first character of the transmission
    // isn't the right character (transmissions must start
    // with a ~)
    if (s[i-1] != '~') { 
      return 1; 
    }

    i = 0;
    // the main loop for reading the serial data
    // into a string buffer
    // one less to have room for terminating '\0'
    while (c != '~' && i < BUF_SIZE-1) {
      while (!Serial.available()) {
        if (millis () - startTime > 5000){
          return 2;
        }
      }
      c = Serial.read();
      if (c != '~') // Transmissions also end with ~
       s[i++] = c;
    }
    //check again for button presses before flushing buffer
    readbutt();
    Serial.flush();
    return 0;
 }
  return 1;
}

void readbutt(){
  if (Serial.peek() == '*') {
    Serial.read ();
    symbol = Serial.read();

    if (symbol == 65)
      ba = 1;

    if (symbol == 66)
      bb = 1;

    if (symbol == 67)
      bc = 1;

    if (symbol == 68)
      bd = 1;
  }
}

int sendSerialData (char *xbee, char *str)
{
  char tx[32];
  sprintf (tx,"~XB=%s,PT=TRB,%s~",xbee,str);
  Serial.print (tx);
  return 0;
}

int sendSerialValveOp (char *xbee, char *str)
{
  char tx[64];
  sprintf (tx, "~XB=%s,PT=VOP,%s~",xbee,str);
  Serial.print (tx);
  return 0;
}

int sendSerialAwk (char *xbee, char *dst)
{
  char tx[32];
  sprintf (tx,"~XB=%s,PT=AWK,DST=%s~",xbee,dst);
  Serial.print (tx);
  return 0;
}