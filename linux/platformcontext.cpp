/*

    OpenPnp-Capture: a video capture subsystem.

    Linux platform code

    Created by Niels Moseley on 7/6/17.
    Copyright © 2017 Niels Moseley. All rights reserved.

    Platform/implementation specific structures
    and typedefs.

*/

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <string>
#include <linux/videodev2.h>

#include "../common/logging.h"
#include "platformstream.h"
#include "platformcontext.h"

// a platform factory function needed by
// libmain.cpp
Context* createPlatformContext()
{
    return new PlatformContext();
}

PlatformContext::PlatformContext() :
    Context()
{
    LOG(LOG_DEBUG, "Context created\n");
    enumerateDevices();
}

PlatformContext::~PlatformContext()
{
}

bool PlatformContext::enumerateDevices()
{
    int fd;
    v4l2_capability  video_cap;

    LOG(LOG_INFO,"Enumerating devices\n");

    const uint32_t maxDevices = 64; // FIXME: is this a sane number for linux?

    uint32_t dcount = 0;
    while(dcount < maxDevices)
    {
        char fname[100];
        snprintf(fname, sizeof(fname), "/dev/video%d", dcount++);

        if ((fd = ::open(fname, O_RDWR /* required */ | O_NONBLOCK)) == -1)
        {
            //LOG(LOG_ERR, "enumerateDevices: Can't open device %s\n", fname);
            continue;
        }

        if (ioctl(fd, VIDIOC_QUERYCAP, &video_cap) == -1)
        {
            ::close(fd);
            LOG(LOG_ERR, "enumerateDevices: Can't get capabilities\n");
            continue;
        }
        else 
        {
            LOG(LOG_INFO,"Name: '%s'\n", video_cap.card);
            LOG(LOG_INFO,"Path: '%s'\n", fname);
            LOG(LOG_INFO,"capflags = %08X\n", video_cap.capabilities);
            LOG(LOG_INFO,"devflags = %08X\n", video_cap.device_caps);

            if ((video_cap.device_caps & V4L2_CAP_READWRITE) != 0)
            {
                LOG(LOG_INFO,"read/write supported\n");
            }
            else
            {
                LOG(LOG_INFO,"read/write NOT supported\n");
            }

            if ((video_cap.device_caps & V4L2_CAP_STREAMING) != 0)
            {
                LOG(LOG_INFO,"streaming I/O supported\n");
            }
            else
            {
                LOG(LOG_INFO,"streaming I/O NOT supported\n");
            }            

            if ((video_cap.device_caps & V4L2_CAP_ASYNCIO) != 0)
            {
                LOG(LOG_INFO,"async I/O supported\n");
            }
            else
            {
                LOG(LOG_INFO,"async I/O NOT supported\n");
            }   

            //printf("Minimum size:\t%d x %d\n", video_cap.minwidth, video_cap.minheight);
            //printf("Maximum size:\t%d x %d\n", video_cap.maxwidth, video_cap.maxheight);
        }

        if ((video_cap.device_caps & V4L2_CAP_VIDEO_CAPTURE) != 0)
        {
            platformDeviceInfo* dinfo = new platformDeviceInfo();
            dinfo->m_name = std::string((const char*)video_cap.card);
            dinfo->m_devicePath = std::string(fname);
            
            // enumerate the frame formats
            v4l2_fmtdesc fmtdesc;
            uint32_t index = 0;
            fmtdesc.type  = V4L2_BUF_TYPE_VIDEO_CAPTURE;

            bool tryMore = true;
            while(tryMore)
            {
                fmtdesc.index = index;
            
                // first we find the pixel format type / fourcc
                if (ioctl(fd, VIDIOC_ENUM_FMT, &fmtdesc) == -1)
                {
                    tryMore = false;
                }
                else
                {
                    LOG(LOG_INFO, "Format %d\n", index);
                    LOG(LOG_INFO, "  FOURCC = %s\n", fourCCToString(fmtdesc.pixelformat).c_str());

                    // .. then we enumerate all the frame buffer sizes for that
                    // pixel format type.
                    uint32_t frmindex = 0;
                    CapFormatInfo cinfo;
                    cinfo.fourcc = fmtdesc.pixelformat;
                    while(queryFrameSize(fd, frmindex, fmtdesc.pixelformat, &cinfo.width, &cinfo.height))
                    {
                        frmindex++;
                        dinfo->m_formats.push_back(cinfo);
                        LOG(LOG_INFO, "  %d x %d\n", cinfo.width, cinfo.height);
                    }
                }
                index++;
            }

            m_devices.push_back(dinfo);
        }

        ::close(fd);         
    }
    return true;
}