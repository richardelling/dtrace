#!/usr/sbin/dtrace -qCs
/*
 * CDDL HEADER START
 *
 *  The contents of this file are subject to the terms of the
 *  Common Development and Distribution License, Version 1.0 only
 *  (the "License").  You may not use this file except in compliance
 *  with the License.
 *
 *  You can obtain a copy of the license at Docs/cddl1.txt
 *  or http://www.opensolaris.org/os/licensing.
 *  See the License for the specific language governing permissions
 *  and limitations under the License.
 *
 * CDDL HEADER END
 *
 * Copyright 2012 Richard Elling, all rights reserved
 */

dtrace:::BEGIN
{
    trace("Tracing... Interval 10 seconds, or Ctrl-C.\n");
}

nfsv3:::op-write-start 
{
    @[probefunc,"size distribution (bytes)"] = 
        quantize(args[2]->data.data_len);
} 

nfsv3:::op-read-start 
{
    @[probefunc,"size distribution (bytes)"] =
        quantize(args[2]->count);
}

profile:::tick-10sec 
{
    printf("%Y\n", walltimestamp);
    printa(@);
    trunc(@);
}
