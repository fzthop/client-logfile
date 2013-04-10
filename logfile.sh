#/usr/bin/bash
logfile=/root/log/logfile
basedir=/root/log

if [ -f $basedir/maillogsendmailall ]; then
    rm $basedir/maillogsendmailall
fi

if [ -f $basedir/maillogsendmaillocal-1 ]; then
    rm $basedir/maillogsendmaillocal-1
fi

if [ -f $basedir/maillogsendmaillocal-3 ]; then
    rm $basedir/maillogsendmaillocal-3
fi

if [ -f $basedir/mailq ]; then
    rm $basedir/mailq
fi

if [ -f $basedir/messagessu ]; then
    rm $basedir/messagessu
fi

if [ -f $basedir/securelogssh ]; then
    rm $basedir/securelogssh
fi

if [ -f $basedir/securelogssh-2 ]; then
    rm $basedir/securelogssh-2
fi

if [ -f $basedir/maillog ]; then
    rm $basedir/maillog
fi

if [ -f $basedir/maillogsendmaillocal ]; then
    rm $basedir/maillogsendmaillocal
fi

if [ -f $basedir/maillogsendmaillocal-2 ]; then
    rm $basedir/maillogsendmaillocal-2
fi 

if [ -f $basedir/maillogsendmaillocal-4 ]; then
    rm $basedir/maillogsendmaillocal-4
fi

if [ -f $basedir/messageslog ]; then
    rm $basedir/messageslog
fi

if [ $basedir/securelog ]; then
    rm $basedir/securelog
fi

if [ $basedir/securelogssh-1 ]; then
    rm $basedir/securelogssh-1
fi

declare -i datenu=`date +%k`
if [ "$datenu" -le "6" ]; then
        date --date='1 day ago' +%b' '%e  > "/var/log/dattime"
else
        date +%b' '%e  > "/var/log/dattime"
fi
y="`cat /var/log/dattime`"

log=`grep 'authpriv\.\*' /etc/syslog.conf | awk '{print $2}'| \
        head -n 1|tr -d '-'`
if [ "$log" == "" ]; then
        echo "Sorry, You do not have the login logfile.... Stop $0"
fi
cat $log | grep "$y" > /root/log/securelog

log=`grep 'mail\.\*' /etc/syslog.conf | awk '{print $2}'| \
        head -n 1|tr -d '-'`
if [ "$log" == "" ]; then
        log=`grep 'mail\.' /etc/syslog.conf | awk '{print $2}'| \
        tr -d '-'|grep -v 'message'`
fi

if [ "$log" == "" ]; then
        echo "Sorry, You do not have the mail logfile.... Stop $0" 
fi

cat $log | grep "$y" > /root/log/maillog

cat /var/log/messages   | grep "$y" > "/root/log/messageslog"

funcssh () {
        echo " "                                        >> $logfile
        echo "================= SSH 的登录档资讯汇整 =======================">> $logfile
        sshright=`cat $basedir/securelog |grep 'sshd.*Accept' | wc -l | \
                awk '{print $1}'`
        if [ "$sshright" != "0" ]; then
                echo "一共成功登入的次数： $sshright" | \
                        awk '{printf("%-26s %3d\n",$1,$2)}'        >> $logfile
                echo "帐号   来源位址 次数 "| \
                        awk '{printf("%-10s %-15s %-4s\n", $1, $2, $3)}'>> $logfile
                cat $basedir/securelog | grep 'sshd.*Accept' | \
                        sed 's/^.*for//g' |awk '{print $1}' \
                        > "$basedir/securelogssh-1"
                cat $basedir/securelog | grep 'sshd.*Accept' | \
                        sed 's/^.*from//g' |awk '{print $1}' \
                        > "$basedir/securelogssh-2"
                paste $basedir/securelogssh-1 $basedir/securelogssh-2  \
                        > $basedir/securelogssh
                /bin/awk '{ for( i=0; i<1; i++ ) Number[$i]++ };
                        END{ for( course in Number )
                        printf( "%-25s %3d\n", course, Number[course])}' \
                        $basedir/securelogssh | sort -k2 -gr  | \
                        awk '{printf("%-10s %-15s %3d\n", $1, $2, $3)}'>> $logfile
                echo " "                                          >> $logfile
        fi
        ssherror=`cat $basedir/securelog | grep "sshd.*Fail" | wc -l | \
                awk '{print $1}'`
        if [ "$ssherror" != "0" ]; then
                echo "一共错误登入的次数: $ssherror" | \
                        awk '{printf( "%-26s %3d\n", $1, $2)}' >> $logfile
                echo "帐号   来源位址 次数 "| \
                        awk '{printf("%-10s %-15s %-4s\n", $1, $2, $3)}'>> $logfile
                cat $basedir/securelog | grep "sshd.*Fail" | \
                        sed 's/^.*for//g' |awk '{print $1}' \
                        >  "$basedir/securelogsshno-1"
                cat $basedir/securelog | grep "sshd.*Fail" | \
                        sed 's/^.*from//g' |awk '{print $1}' \
                        >  "$basedir/securelogsshno-2"
                paste $basedir/securelogsshno-1 $basedir/securelogsshno-2 \
                        > $basedir/securelogsshno
                /bin/awk '{ for( i=0; i<1; i++ ) Number[$i]++ };
                        END{ for( course in Number )
                        printf( "%-25s %3d\n", course, Number[course])}' \
                        $basedir/securelogsshno |sort -k2 -gr  | \
                        awk '{printf("%-10s %-15s %3d\n", $1, $2, $3)}' >> $logfile
                echo " "                           >> $logfile
        fi
        
        cat $basedir/messageslog | grep "su"|grep "open"|grep "root"| \
                sed 's/^.*by//g' |awk '{print $1}'|sort   >  $basedir/messagessu
        sshsu=`wc -l $basedir/messagessu | awk '{print $1}'`
        if [ "$sshsu" != "0" ]; then
                echo "以 su 转换成 root 的使用者及次数"                >> $logfile
                echo "帐号   次数 "| \
                        awk '{printf("%-26s %-4s\n", $1, $2)}'      >> $logfile
                /bin/awk '{ for( i=0; i<1; i++ ) Number[$i]++ };
                        END{ for( course in Number )
                        printf( "%-25s %3d\n", course, Number[course])}' \
                        $basedir/messagessu   | sort -k2 -gr | \
                        awk '{printf("%-25s %3d\n", $1, $2)}'       >> $logfile
                echo " "                                    >> $logfile
        fi
        if [ "$sshright" == "0" ] && [ "$ssherror" == "0" ]; then
                echo "今日没有使用 SSH 的纪录"              >> $logfile
                echo " "                                     >> $logfile
        fi
}

# 3 POP3 的登录资料的功能函数 (Function) ！
funcpop3 () {
        echo "================= POP3 的登录档资讯汇整 ======================"  >> $logfile
        pop3right=`cat $basedir/maillog|grep "pop3.*Login user" |  wc -l | \
                awk '{print $1}'`
        if [ "$pop3right" != "0" ]; then
                echo "POP3登入次数: $pop3right" | \
                        awk '{printf( "%-40s %4d\n", $1, $2)}'           >> $logfile
                echo "帐号   来源位址 次数 "|  \
                        awk '{printf("%-15s %-25s %-4s\n", $1, $2, $3)}' >> $logfile
                cat $basedir/maillog | grep "pop3.*Login user" |\
                        sed 's/^.*user=//g' | awk '{print $1}' \
                        > $basedir/maillogpop-1
                cat $basedir/maillog | grep "pop3.*Login user" |\
                        sed 's/^.*host=//g' | sed 's/^.*\[//g' |\
                        sed 's/\].*$//g' | awk '{print $1}' \
                        > $basedir/maillogpop-2
                paste $basedir/maillogpop-1 $basedir/maillogpop-2 \
                        > $basedir/maillogpop
                /bin/awk '{ for( i=0; i<1; i++ ) Number[$i]++ };
                        END{ for( course in Number )
                        printf( "%-35s %4d\n", course, Number[course])}' \
                        $basedir/maillogpop   | sort +2 -gr | \
                        awk '{printf("%-15s %-25s %3d\n", $1, $2, $3)}'>> $logfile
                echo " "                                              >> $logfile
        fi
        pop3error=`cat $basedir/messageslog|grep "pop3.*Login fail"| \
                 wc -l |  awk '{print $1}'`
        if [ "$pop3error" != "0" ]; then
                echo "POP3错误登入次数: $pop3error" | \
                        awk '{printf( "%-40s %4d\n", $1, $2)}'        >> $logfile
                echo "帐号   来源位址 次数 "|  \
                        awk '{printf("%-15s %-25s %-4s\n", $1, $2, $3)}'>> $logfile
                cat $basedir/messageslog | grep "pop3.*Login fail" |\
                        sed 's/^.*user=//g' | awk '{print $1}' \
                        > $basedir/maillogpopno-1
                cat $basedir/messageslog | grep "pop3.*Login fail" |\
                        sed 's/^.*host=//g' | sed 's/^.*\[//g' |\
                        sed 's/\].*$//g' | awk '{print $1}' \
                        > $basedir/maillogpopno-2
                paste $basedir/maillogpopno-1 $basedir/maillogpopno-2 \
                        > $basedir/maillogpopno
                /bin/awk '{ for( i=0; i<1; i++ ) Number[$i]++ };
                        END{ for( course in Number )
                        printf( "%-35s %4d\n", course, Number[course])}' \
                        $basedir/maillogpopno | sort -k2 -gr | \
                        awk '{printf("%-15s %-25s %3d\n", $1, $2, $3)}'   >> $logfile
                        echo " "                                     >> $logfile
        fi
        if [ "$pop3error" == "0" ] && [ "$pop3right" == "0" ]; then
                echo "今日没有使用 POP3 的纪录"                     >> $logfile
                echo " "                                             >> $logfile
        fi
}

funcsendmail () {
        echo "================= Sednamil 的登录档资讯汇整 ==================" >> $logfile
        auth=no
        [ -f /usr/lib/sasl/Sendmail.conf ]  && auth=yes
        [ -f /usr/lib/sasl2/Sendmail.conf ] && auth=yes
        if [ "$auth" == "yes" ]; then
                echo "您的主机有进行 SASL 身份认证的功能"        >> $logfile
        else
                echo "您的主机没有进行 SASL 身份认证的功能"       >> $logfile
        fi
        echo " "                                         >> $logfile
        sendmailright=`cat $basedir/maillog|grep "sendmail.*from.*class" | \
                 wc -l | awk '{print $1}'`
        if [ "$sendmailright" != "0" ]; then
                echo "SMTP共受信次数: $sendmailright " | \
                        awk '{printf( "%-21s %10d\n", $1, $2)}'   >> $logfile
                cat $basedir/maillog |grep "sendmail.*from.*class" |\
                        sed 's/^.*size=//g' | awk -F ',' '{print $1}' \
                        > $basedir/maillogsendmailall
                mailsize=`awk '{ smtp = smtp + $1 } END {print smtp/1024}' \
                        $basedir/maillogsendmailall`
                echo "共收受信件的容量大小: $mailsize KBytes" | \
                        awk '{printf( "%-20s %10d %-8s\n",$1, $2, $3)}'>> $logfile
                echo " "                                             >> $logfile
        fi
        echo " " > $basedir/maillogsendmaillocal-1
        echo " " > $basedir/maillogsendmaillocal-2
        echo " " > $basedir/maillogsendmaillocal-3
        cat $basedir/maillog |grep "sendmail.*from.*mech=LOGIN" | \
                sed 's/^.*from=//g' |  awk -F ',' '{print $1}' \
                >> $basedir/maillogsendmaillocal-1
        cat $basedir/maillog |grep "sendmail.*from.*mech=LOGIN" | \
                sed 's/^.*relay=//g' |  awk '{print $1}' |\
                awk '{print $1 ","}' \
                >> $basedir/maillogsendmaillocal-2
        cat $basedir/maillog |grep "sendmail.*from.*mech=LOGIN" | \
                sed 's/^.*size=//g' |  awk -F ',' '{print $1}' \
                >> $basedir/maillogsendmaillocal-3
        cat $basedir/maillog |grep "sendmail.*from.*localhost" | \
                sed 's/^.*from=//g' |  awk -F ',' '{print $1}' \
                >> $basedir/maillogsendmaillocal-1
        cat $basedir/maillog |grep "sendmail.*from.*localhost" | \
                sed 's/^.*relay=//g' |  awk '{print $1 ","}' \
                >> $basedir/maillogsendmaillocal-2
        cat $basedir/maillog |grep "sendmail.*from.*localhost" | \
                sed 's/^.*size=//g' |  awk -F ',' '{print $1}' \
                >> $basedir/maillogsendmaillocal-3
        paste $basedir/maillogsendmaillocal-1  \
                $basedir/maillogsendmaillocal-2 \
                > $basedir/maillogsendmaillocal-4
        paste $basedir/maillogsendmaillocal-4  \
                $basedir/maillogsendmaillocal-3 \
                > $basedir/maillogsendmaillocal
        declare -i sendmaillocal=`cat $basedir/maillogsendmaillocal| \
                wc -l| awk '{print $1}'`
        sendmaillocal=$sendmaillocal-1
        if [ "$sendmaillocal" != "0" ]; then
                echo "SMTP本机登入次数: $sendmaillocal" | \
                        awk '{printf( "%-21s %10d\n", $1, $2)}'   >> $logfile
                mailsize=`awk '{ smtp = smtp + $1 } END {print smtp/1024}' \
                        $basedir/maillogsendmaillocal-3`
                echo "共收受信件的容量大小: $mailsize KBytes" | \
                        awk '{printf( "%-20s %10d %-8s\n",$1, $2, $3)}'  >> $logfile
                echo " "                                            >> $logfile
                echo "帐号   来源位址 次数 信件容量(KBytes)"| \
                awk '{printf("%-35s %-35s %-6s %-10s\n", $1, $2, $3, $4)}'>> $logfile
                awk '{FS=","}{if(NR>=2) for( i=1; i<2; i++ ) (sizes[$i]=sizes[$i]+$2/1024) && Number[$i]++ };
                        END{ for( course in Number )
                        printf( "%-80s %-10s %-10s\n", course, Number[course], sizes[course])}' \
                        $basedir/maillogsendmaillocal| sort -k2 -gr |\
                        awk '{printf("%-35s %-35s %4d %10d\n", $1, $2, $3, $4)}' >> $logfile
                echo " "                            >> $logfile
        fi
        if [ -x /usr/bin/mailq ] ; then
                mailq > $basedir/mailq
                declare -i mailq=`wc -l $basedir/mailq | awk '{print $1}'`
                if [ "$mailq" -ge "3" ] ; then
                        echo "放在邮件伫列当中的信件资讯"     >> $logfile
                        cat $basedir/mailq                       >> $logfile
                        echo " "                             >> $logfile
                fi
        fi
        sendmailerror=`cat $basedir/maillog | grep "sendmail.*reject=" | wc -l | \
                awk '{print $1}'`
        if [ "$sendmailerror" != "0" ]; then
                echo "错误的邮件资讯：提供系馆管理员处理用"           >> $logfile
                cat $basedir/maillog | grep "sendmail.*reject="       >> $logfile
                echo " "                                            >> $logfile
        fi
        if [ "$sendmailright" == "0" ] && [ "$sendmaillocal" == "0" ] \
                && [ "$sendmailerror" == "0" ]; then
                echo "今日没有 sendmail 的相关资讯"                >> $logfile
                echo " "                                          >> $logfile
        fi
}

if [ -f $basedir/logfile ]; then
    rm $basedir/logfile
fi

funcssh
funcpop3
funcsendmail

exit 3
