# makefile for openpnp-captur, macOS

all: linux/libopenpnp-capture.a

BITS?=64
ifeq ($(BITS),32)
NDK=/clear/android/
CFLAGS = -march=armv7 
CXX = $(NDK)/bin/arm-linux-androideabi-clang++ --sysroot=$(NDK)/sysroot
else
NDK=/clear/android64/
CFLAGS = -march=armv8-a
CXX  =$(NDK)/bin/aarch64-linux-android-clang++ --sysroot=$(NDK)/sysroot 
endif

PLATFORM="Linux $(BITS) bit release"
CFLAGS += -std=c++11 
CFLAGS += -Os -D__BUILDTYPE__='"release"'
CFLAGS += -pipe -U_FORTIFY_SOURCE -fPIE 
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
