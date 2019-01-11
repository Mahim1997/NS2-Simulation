print "first argument     : ", ARG1
print "script name        : ", ARG0
print "second argument     : ", ARG2
print "third argument     : ", ARG3 
print "fourth argument     : ", ARG4
print "fifth argument     : ", ARG5
print "number of arguments: ", ARGC 

#ARG4 is the text file to be plotted
#ARG5 is the output file name in which image is saved

set title ARG1
set xlabel ARG2
set ylabel ARG3

set grid
plot ARG4 with linespoints title ARG1 ;

#plot ARG4 title ARG1 ;

set term png
set output ARG5
replot