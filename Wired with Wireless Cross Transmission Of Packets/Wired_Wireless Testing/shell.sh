
clear;
traceFile="wired-and-wireless.tr";

awkWireless="awkFile.awk";
awkWired="wiredAwk.awk";
tclFile="tclFile.tcl";

echo "Running tcl file now for Wired-Wireless Cross Transmission";
ns "$tclFile" ;

echo ;
echo "Running awk file now for wireless nodes .";
awk -f "$awkWireless" "$traceFile";


echo ;

echo "Now Running awk file for WIRED nodes...";

awk -f "$awkWired" "$traceFile"

echo ;
echo "Running nam file now .";

nam wired-and-wireless.nam & 
