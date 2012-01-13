#!/usr/sbin/dtrace -Cs

/* 
 * compliments of Brendan Gregg
 * http://dtrace.org/blogs/brendan/2012/01/09/activity-of-the-zfs-arc/
 * modified to show distributions by Richard Elling, 12-jan-12
 */

#pragma D option quiet

dtrace:::BEGIN
{
    trace("Tracing ARC evicts for distributions, 10 second samples...\n");
}

fbt::arc_evict:entry
{
    this->s = arg4 == 0 ? "data" : "metadata";
    this->t = arg3 == 0 ? "evict" : "recycle";
    @[this->s, this->t, arg2] = count();
}

profile:::tick-10sec
{
    printf("%Y\n", walltimestamp);
    printa("%8s\t%8s\t%15d\t%@d\n", @);
    trunc(@);
}