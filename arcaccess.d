#!/usr/sbin/dtrace -Cs

/* 
 * compliments of Brendan Gregg
 * http://dtrace.org/blogs/brendan/2012/01/09/activity-of-the-zfs-arc/
 */

#pragma D option quiet

dtrace:::BEGIN
{
    printf("lbolt rate is %d Hertz.\n", `hz);
    printf("Tracing lbolts between ARC accesses...");
}

fbt::arc_access:entry
{
    self->ab = args[0];
    self->lbolt = args[0]->b_arc_access;
}

fbt::arc_access:return
/self->lbolt/
{
    @ = quantize(self->ab->b_arc_access - self->lbolt);
    self->ab = 0;
    self->lbolt = 0;
}
