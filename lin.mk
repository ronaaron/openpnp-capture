# makefile for openpnp-captur, macOS

all: linux/libopenpnp-capture.a

BITS?=64
ifeq ($(BITS),32)
CFLAGS = -m32
CXX = clang++-3.8
else
CFLAGS = -m64
CXX = clang++
endif

PLATFORM="Linux $(BITS) bit release"
CFLAGS += -stdlib=libc++ -std=c++11 -msse2
CFLAGS += -O2 -D__BUILDTYPE__='"release"'
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
