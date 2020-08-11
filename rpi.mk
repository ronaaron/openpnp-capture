# makefile for openpnp-captur, macOS

all: linux/libopenpnp-capture.a

BITS?=64
ifeq ($(BITS),32)
RPI=/clear/pi/tools/arm-bcm2708/arm-linux-gnueabihf/bin/arm-linux-gnueabihf
CFLAGS = -march=armv6 -mtune=arm1176jzf-s -mfpu=vfp  -mfloat-abi=hard -mno-unaligned-access -mhard-float -marm
else
RPI= /clear/rpi64/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu
CFLAGS = -march=armv8-a -mtune=cortex-a53
endif
CXX = $(RPI)-g++

PLATFORM="Linux $(BITS) bit release"
CFLAGS += -std=c++11 
CFLAGS += -Os -D__BUILDTYPE__='"release"'
CFLAGS += -pipe -U_FORTIFY_SOURCE -fpie 
CFLAGS += -Ilinux/contrib/libjpeg-turbo-dev -Iinclude -I. -D__PLATFORM__='$(PLATFORM)'

SRC = 	linux/platformcontext.cpp linux/platformstream.cpp linux/mjpeghelper.cpp linux/yuvconverters.cpp \
	common/context.cpp common/libmain.cpp common/logging.cpp  common/stream.cpp

OBJS = $(subst .cpp,.o,$(subst .mm,.o,$(SRC)))

linux/libopenpnp-capture.a: $(OBJS)
	ar rc $@ $(OBJS)
	@ranlib $@

clean:
	-@rm $(OBJS) linux/libopenpnp-capture.a

%.o: %.cpp 
	$(info compiling $<)
	@$(CXX) $(CFLAGS) -c -o $@ $< 
	
%.o: %.mm
	$(info compiling $<)
	@$(CXX) $(CFLAGS) -c -o $@ $< 
