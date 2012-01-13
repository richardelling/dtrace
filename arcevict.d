#!/usr/sbin/dtrace -Cs

/* 
 * compliments of Brendan Gregg
 * http://dtrace.org/blogs/brendan/2012/01/09/activity-of-the-zfs-arc/
 */

#pragma D option quiet

dtrace:::BEGIN
{
    trace("Tracing ARC evicts...\n");
}

fbt::arc_evict:entry
{
    this->s = arg4 == 0 ? "data" : "metadata";
    this->t = arg3 == 0 ? "evict" : "recycle";
    printf("%Y %-10a %-10s %-10s %d bytes\n", walltimestamp, args[0],
        this->s, this->t, arg2);
}
