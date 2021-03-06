void txandtr(){
  //  /* Send valve state and psi data every 30 sec */
  if (millis()-lastSerialTX >= 60000ul*5ul) {// &&&&& when this number is above 1000*30, it never enters this if loop!!! ideally this number should be set to 10 minutes 
    lastSerialTX = millis();
    sendSerialStatus();
  }

  /*	Check for remote commands	*/
  if (getSerialData(rx.str) == 0) { 
    parseData (rx.data,rx.str);

    //is well formed, has packet type, is for us?
    if ((keyExists(rx.data,"XB") && 
      keyExists(rx.data,"PT") &&
      keyExists(rx.data,"DST") && 
      strcmp(getDataVal(rx.data,"DST"),XBEE) == 0)) {

         
      //BTN packet type - old method for controlling valves,
      //send from the controller
      if (strcmp(getDataVal(rx.data,"PT"),"BTN") == 0) {
        // if A1 is toggled open valve
        if (keyExists(rx.data,"A1") && atoi(getDataVal(rx.data,"A1")) == 1)
          openFunct();
        if (keyExists(rx.data,"A2") && atoi(getDataVal(rx.data,"A2")) == 1)
          closeFunct();
        sendSerialAwk(XBEE,getDataVal(rx.data,"XB"));
      }//BTN


      //Destinational ping request
      else if (strcmp(getDataVal(rx.data,"PT"),"PING") == 0) {
        Serial.print("~XB=TRB,PT=PONG~"); //respond to pings
        sendSerialStatus();
      }
      //set control mode, 0 for auto, 1 for manual
      else if(strcmp(getDataVal(rx.data,"PT"),"SCM") == 0 &&
        keyExists(rx.data,"M")) {
        if (strcmp(getDataVal(rx.data,"M"),"0") == 0) {
          resetAutoMode();
        }
        else if (strcmp(getDataVal(rx.data,"M"),"1") == 0) {
          controlMode = 1;
        }
        sendSerialAwk(XBEE,getDataVal(rx.data,"XB"));
      }//SCM

      //Set Valve State - explicit valve state change request
      else if(strcmp(getDataVal(rx.data,"PT"),"SVS") == 0 &&
        keyExists(rx.data,"VS")) {
        //check for up/down symbols '+' and '-'
        if (strcmp(getDataVal(rx.data,"VS"), "-") == 0) closeFunct();
        else if (strcmp(getDataVal(rx.data,"VS"), "+") == 0) openFunct();

        else { //else, use atoi, remember returns 0 for junk data
          if (strcmp(getDataVal(rx.data,"VS"), "0") == 0) setValveState(0);
          else {
            int i = atoi(getDataVal(rx.data,"VS"));
            if (i>0) setValveState(i);
          }
        }
        sendSerialAwk(XBEE,getDataVal(rx.data,"XB"));
      }//VSR

      //Set Testing Mode - test mode on or off
      //not being used much - probably could go, along with the
      //bit field associated in the status packet
      else if (strcmp(getDataVal(rx.data,"PT"),"STM") == 0 &&
        keyExists(rx.data,"M")) {
        if (strcmp(getDataVal(rx.data,"M"),"0") == 0) {
          testing = false;
          snprintf(title, 16, "Testing: off");
          printInfo();
        }
        else if (strcmp(getDataVal(rx.data,"M"),"1") == 0) {
          testing = true;
          snprintf(title, 16, "Testing: on");
          printInfo();
        }
        sendSerialAwk(XBEE,getDataVal(rx.data,"XB"));
      }//STM

    }//well formed

    //These packets have no DST field
    else if( keyExists(rx.data, "PT") ) {

      if (strcmp(getDataVal(rx.data,"PT"),"PING") == 0) {
        Serial.print("~XB=TRB,PT=PONG~"); //respond to pings
        sendSerialStatus();
      }//PING

      //WTT packet - ckeck for >4000 watts; step down immediately, 0r > 3800, step down if a sencond shows up > 3800
      else if( strcmp(getDataVal(rx.data, "PT"), "WTT") == 0)  {
        if (atoi(getDataVal(rx.data, "W")) > WATT_HARD_THRESHOLD)
          closeFunct(); //step down if we hear about >4000 watt production
       
        else if (seenSoftThreshold) { //step down if we see > soft threshold twice;
          if (atoi(getDataVal(rx.data, "W")) > WATT_SOFT_THRESHOLD)
            closeFunct();
          else 
            seenSoftThreshold = false;
        }
        
        else if (atoi(getDataVal(rx.data, "W")) > WATT_SOFT_THRESHOLD)
          seenSoftThreshold = true; 
        
      }
    }

  }//got data
}//txandtr()










