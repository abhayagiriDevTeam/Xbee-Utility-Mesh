// set to true if you want to use the Upper Water Shed
#define USE_HydroWatts	false

// LED Pins for Roamer
#define    LED_1    A3
#define    LED_2    A4
#define    LED_3    A5
// LED Pins for MUB
//#define    LED_1    10
//#define    LED_2    11
//#define    LED_3    12

//Location Name (XB ID)
#define XBEE    "MUB"
// Number of display modes for LCD
#define DISPLAY_MODES	2
// Size of array for storing recieved serial data
#define BUF_SIZE  128
// Number of entries that can be recieved over serial
#define KEYS_MAX 16
// Max size of each entry
#define ENT_SIZE 16
// Number of water tanks
#define	TANK_NUM 3
// Length of id string that comes from remote source (ie: INV, TWT, FWT)
#define ID_LENGTH 4	// Remember actual length is one less due to zero
			// termination of strings


// Turbine Error Limit (if watt reading from Upper Water Shed fall too far
// there is probably a problem with the turbine)
#define WATTS_ERROR_LEVEL	40
bool hydroError = false;

// Tank enumation
#define	TWT	0
#define	FWT	1
#define RDG	2

// Macro to calculate size of array
#define LENGTH(a,t)	((sizeof(a))/(sizeof(t)))

// struct used to keep track of which type of data to display;
struct configStruct {
	int displayMode; // current type of data to display
			// 0 = default
			// 1 = Water Tanks
	int pauseCounter;
	bool	dispModeSwitched;
	int indexDefault;
	int indexTank; 		// tank to display data for 
	int indexBattery;	// section of battery data to display
	int indexTurbine;	// section of the hydro program data to display
	int indexHydroWatts;
} config = {0,0,false,0,0,0,0,0};

struct timerStruct {
	unsigned long day;
	int hour;
	int min;
	int sec;
	bool justOverflowed;
};
struct timerStruct timer = {0,0,0,0,false};

// Structure type for holding recently received data
struct dataStruct {
	char key[ENT_SIZE];
	char val[ENT_SIZE];
};

// Structure for water tank data
struct tankStruct {
	char id[ID_LENGTH];	// Three bytes for XBee ID,
				// 4th byte is null termination
	int level;
	struct timerStruct timeStamp; // timestamp to calculate time
					// since last data came in
} tanks[TANK_NUM];

// Structure for water tank data
struct turbineStruct {
	char id[ID_LENGTH];	// Three bytes for XBee ID,
				// 4th byte is null termination
	char valves[5];		// holds valve status
	int psi;		// holds turbine psi
	struct timerStruct timeStamp; // timestamp to calculate time
					// since last data came in
} turbine;

// Structure for water tank data
struct hydroWattsStruct {
	char id[ID_LENGTH];	// Three bytes for XBee ID,
				// 4th byte is null termination
	unsigned int watts;		// holds watts produced by hydro
	struct timerStruct timeStamp; // timestamp to calculate time
					// since last data came in
} hydroWatts;


// Structure for battery room data
struct batteryStruct {
	char id[ID_LENGTH];	// Three bytes for XBee ID,
				// 4th byte is null termination
	int status;
	char volts[6];
	char hourVolts[6];
	// Arduino sprintf doesn't print floats
	//float hourVolts;
	//float volts;
	int watts;
	struct timerStruct timeStamp; // timestamp to calculate time
					// since last data came in
} battery;

struct packetStruct{
	char str[BUF_SIZE];
	struct dataStruct data[KEYS_MAX];
};
packetStruct rx = { };

struct buttonStruct {
	int a1;
	int a2;
	int b1;
	int b2;
} button = {0,0,0,0}, buttonLast = {0,0,0,0};
