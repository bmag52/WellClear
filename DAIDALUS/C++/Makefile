# Simple Makefile to build DAIDALUS library and example applications

SRC0   = $(wildcard src/*.cpp)
SRC1   = $(SRC0:src/DaidalusExample.cpp=)
SRC2   = $(SRC1:src/DaidalusAlerting.cpp=)
SRCS   = $(SRC2:src/DaidalusBatch.cpp=)
RTOS   = ../../rtos/apps
OBJS   = $(SRCS:.cpp=.o)
INCLUDEFLAGS = -Iinclude

# Include the Directories required for the drivers:
#########################################################################
INCLReqDrv   = -I$(RTOS)/include/drivers
# INCLReqDrv  += -I$(RTOS)/include/lib/stdlib
INCLReqDrv  += -I$(RTOS)/include/common
INCLReqDrv  += -I$(RTOS)/include/lib
INCLReqDrv  += -I$(RTOS)/include/plat
# INCLReqDrv  += -I$(RTOS)/include/lib/stdlib
# INCLReqDrv  += -I$(RTOS)/include/lib/stdlib/sys

CXX=aarch64-linux-gnu-g++
CXXFLAGS = $(INCLUDEFLAGS) $(INCLReqDrv) -Wall -O

# Create RTOSLIB variable
RTOSLIB = librtos.o

all: lib examples

lib: $(OBJS)
	@echo 
	@echo "** Building DAIDALUS library"
	ar -cr lib/DAIDALUS.a $(OBJS)
	ranlib lib/DAIDALUS.a
	rm src/*.o
	@echo 

examples:
	@echo
	@echo "** Building example applications"
	$(CXX) -o DaidalusExample $(CXXFLAGS) src/DaidalusExample.cpp lib/DAIDALUS.a
	$(CXX) -o DaidalusAlerting $(CXXFLAGS) src/DaidalusAlerting.cpp lib/DAIDALUS.a
	$(CXX) -o DaidalusBatch $(CXXFLAGS) src/DaidalusBatch.cpp lib/DAIDALUS.a
	@echo "** To run DaidalusExample type:"
	@echo "./DaidalusExample"
	@echo "** To run DaidalusAlerting type, e.g.,"
	@echo "./DaidalusAlerting --conf ../Configurations/WC_SC_228_nom_b.txt --out H1.csv ../Scenarios/H1.daa"
	@echo "** To run DaidalusBatch type, e.g.,"
	@echo "./DaidalusBatch --conf ../Configurations/WC_SC_228_nom_b.txt --out H1.out ../Scenarios/H1.daa"

clean:
	rm -f DaidalusExample $(OBJS) lib/DAIDALUS.a

# Add The created variable to the linker
# Link u-boot 
##########################################################################
$(LDOBJ): $(OBJS)
	$(LD) $(LDflags) $(OBJS) $(RTOSLIB) -o $(LDOBJ) -Map app1.map

.PHONY: all lib example
