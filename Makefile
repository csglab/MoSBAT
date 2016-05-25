MAKE = make		#change this line if you are using a different GNU make software

dirSeq = ./src/_seq
dirDB = ./src/_motifdb
dirAffiMx = ./src/AffiMx

all: Extract MK_dir CC_AffiMx RM_objectFiles

Extract:
	gunzip $(dirSeq)/*.gz $(dirDB)/*.gz

MK_dir:
	mkdir -p ./bin

CC_AffiMx: $(dirAffiMx)/Makefile
	$(MAKE) -C $(dirAffiMx)
	
RM_objectFiles:
	rm -f $(dirAffiMx)/*.o

clean:
	rm -f $(dirAffiMx)/*.o
