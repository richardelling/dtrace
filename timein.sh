#!/usr/bin/bash
#
# timein.sh shows the distribution of time spent in a function
# usage: function-spec [threshold]
# 
# if a function takes longer than threshold nanoseconds (default
# is 1,000,000 (1 millisecond)) then also collect the calling
# stack.
#
# CDDL HEADER START
#
#  The contents of this file are subject to the terms of the
#  Common Development and Distribution License, Version 1.0 only
#  (the "License").  You may not use this file except in compliance
#  with the License.
#
#  You can obtain a copy of the license at Docs/cddl1.txt
#  or http://www.opensolaris.org/os/licensing.
#  See the License for the specific language governing permissions
#  and limitations under the License.
#
# CDDL HEADER END

# Version 1.1 29-dec-2011 Richard.Elling@nexenta.com

# Copyright 2011 Nexenta Systems, Inc. All rights reserved.

PATH=/usr/sbin:/usr/bin
INTERVAL=10s

FUNCTION=$1

if [ -z "$FUNCTION" ]; then
        echo "error: no kernel function specified"
        exit 1
fi

THRESHOLD=$2
if [ -z "$THRESHOLD" ]; then
        THRESHOLD=1000000
fi

dtrace -Cn '
#pragma D option quiet
#pragma D option dynvarsize=4m

dtrace:::BEGIN { trace("Tracing... Interval '$INTERVAL', or Ctrl-C.\n"); }

'$FUNCTION':entry
{
        self->ts = timestamp;
}

'$FUNCTION':return
/self->ts && ((this->t = (timestamp - self->ts)) > '$THRESHOLD')/
{
        @s[stack()] = count();
}

'$FUNCTION':return
/self->ts/
{
        t = timestamp - self->ts;
        @l = quantize(t);
        self->ts = 0;
}

profile:::tick-'$INTERVAL',
dtrace:::END
{
        printf("%Y\t'$FUNCTION'\tnanoseconds", walltimestamp);
        printa(@l);
        trunc(@l);
        printa(@s);
        trunc(@s);
}
'
