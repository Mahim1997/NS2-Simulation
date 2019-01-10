
clear;
traceFile="wired-and-wireless.tr";
ns tclFile.tcl

echo ;
echo "Running awk file now .";

awk -f awkFile.awk "$traceFile";

echo ;
echo "Running nam file now .";

nam wired-and-wireless.nam & 