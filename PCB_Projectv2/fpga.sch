EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L tinyFPGA:tinyFPGA_AX2 U?
U 1 1 5F5E4FAC
P 5550 3350
F 0 "U?" H 5550 4125 50  0000 C CNN
F 1 "tinyFPGA_AX2" H 5550 4034 50  0000 C CNN
F 2 "" H 5550 3450 50  0001 C CNN
F 3 "" H 5550 3450 50  0001 C CNN
	1    5550 3350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5F5E61A1
P 4250 2800
F 0 "#PWR?" H 4250 2550 50  0001 C CNN
F 1 "GND" H 4255 2627 50  0000 C CNN
F 2 "" H 4250 2800 50  0001 C CNN
F 3 "" H 4250 2800 50  0001 C CNN
	1    4250 2800
	-1   0    0    1   
$EndComp
$Comp
L power:+3.3V #PWR?
U 1 1 5F5E69E4
P 6800 2800
F 0 "#PWR?" H 6800 2650 50  0001 C CNN
F 1 "+3.3V" H 6815 2973 50  0000 C CNN
F 2 "" H 6800 2800 50  0001 C CNN
F 3 "" H 6800 2800 50  0001 C CNN
	1    6800 2800
	1    0    0    -1  
$EndComp
Text Label 4250 2900 0    50   ~ 0
reset
Text Label 4250 3600 0    50   ~ 0
taster0
Text Label 4250 3700 0    50   ~ 0
taster1
Text Label 4250 3800 0    50   ~ 0
taster2
Text Label 4250 3900 0    50   ~ 0
taster3
Text Label 6800 2900 0    50   ~ 0
relais0
Text Label 6800 3000 0    50   ~ 0
relais1
Text Label 6800 3100 0    50   ~ 0
relais2
Text Label 6800 3200 0    50   ~ 0
relais3
Text Label 6800 3300 0    50   ~ 0
serial_enable
Text Label 6800 3400 0    50   ~ 0
serial_out
Text Label 6800 3500 0    50   ~ 0
serial_in
NoConn ~ 4250 3000
NoConn ~ 4250 3100
NoConn ~ 4250 3200
NoConn ~ 4250 3300
NoConn ~ 4250 3400
NoConn ~ 4250 3500
NoConn ~ 6800 3600
NoConn ~ 6800 3700
NoConn ~ 6800 3800
NoConn ~ 6800 3900
$Comp
L power:GND #PWR?
U 1 1 5F5E8192
P 5650 4500
F 0 "#PWR?" H 5650 4250 50  0001 C CNN
F 1 "GND" H 5655 4327 50  0000 C CNN
F 2 "" H 5650 4500 50  0001 C CNN
F 3 "" H 5650 4500 50  0001 C CNN
	1    5650 4500
	1    0    0    -1  
$EndComp
Text Label 5350 4500 1    50   ~ 0
TMS
Text Label 5450 4500 1    50   ~ 0
TCK
Text Label 5550 4500 1    50   ~ 0
TDI
Text Label 5750 4500 1    50   ~ 0
TDO
Wire Wire Line
	4250 2800 4650 2800
Wire Wire Line
	4250 2900 4650 2900
Wire Wire Line
	4250 3000 4650 3000
Wire Wire Line
	4250 3100 4650 3100
Wire Wire Line
	4250 3200 4650 3200
Wire Wire Line
	4250 3300 4650 3300
Wire Wire Line
	4250 3400 4650 3400
Wire Wire Line
	4250 3500 4650 3500
Wire Wire Line
	4250 3600 4650 3600
Wire Wire Line
	4250 3700 4650 3700
Wire Wire Line
	4250 3800 4650 3800
Wire Wire Line
	4250 3900 4650 3900
Wire Wire Line
	6450 2800 6800 2800
Wire Wire Line
	6450 2900 6800 2900
Wire Wire Line
	6450 3000 6800 3000
Wire Wire Line
	6450 3100 6800 3100
Wire Wire Line
	6450 3200 6800 3200
Wire Wire Line
	6450 3300 6800 3300
Wire Wire Line
	6450 3400 6800 3400
Wire Wire Line
	6450 3500 6800 3500
Wire Wire Line
	6800 3600 6450 3600
Wire Wire Line
	6800 3700 6450 3700
Wire Wire Line
	6800 3800 6450 3800
Wire Wire Line
	6800 3900 6450 3900
Wire Wire Line
	5350 4500 5350 4250
Wire Wire Line
	5450 4500 5450 4250
Wire Wire Line
	5550 4500 5550 4250
Wire Wire Line
	5650 4500 5650 4250
Wire Wire Line
	5750 4500 5750 4250
$EndSCHEMATC
