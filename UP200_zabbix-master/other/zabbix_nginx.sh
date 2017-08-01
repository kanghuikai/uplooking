#!/bin/bash
FUN ()
{
curl www.abc.com/status /task 2> /dev/null
}
case $1 in 
	active_connection)
	FUN | sed -n '1p' | awk -F: '{print $2}'
	;;
	accepts)
	FUN | sed -n '3p' |  awk '{print $1}'
	;;
	handled)
	FUN | sed -n '3p'  |  awk '{print $2}'
	;;
	reading)
	FUN  | sed -n '4p' |  awk '{print $2}'
	;;
	writing)
	FUN  | sed -n '4p' |  awk '{print $4}'
	;;
	waiting)
	FUN  | sed -n '4p' |  awk '{print $6}'
	;;
esac




