#!/system/bin/sh
huskydg=`getprop ro.huskydg.initmode`
priv_dir=/data/data/com.github.huskydg.vmostool




TOOLVERAPP=2.0.2
TOOLVERCODEAPP=20002

p(){
COLOR=$1;TEXT="$2";escape="$1"
[ "$COLOR" == "black" ] && escape="0;30"
[ "$COLOR" == "red" ] && escape="0;31"
[ "$COLOR" == "green" ] && escape="0;32"
[ "$COLOR" == "orange" ] && escape="0;33"
[ "$COLOR" == "blue" ] && escape="0;34"
[ "$COLOR" == "purple" ] && escape="0;35"
[ "$COLOR" == "cyan" ] && escape="0;36"
[ "$COLOR" == "light_gray" ] && escape="0;37"
[ "$COLOR" == "gray" ] && escape="1;30"
[ "$COLOR" == "light_red" ] && escape="1;31"
[ "$COLOR" == "light_green" ] && escape="1;32"
[ "$COLOR" == "yellow" ] && escape="1;33"
[ "$COLOR" == "light_blue" ] && escape="1;34"
[ "$COLOR" == "light_purple" ] && escape="1;35"
[ "$COLOR" == "light_cyan" ] && escape="1;36"
[ "$COLOR" == "white" ] && escape="1;37"
[ "$COLOR" == "none" ] && escape="0"
code="\033[${escape}m"
end_code="\033[0m"
echo -n "$code$TEXT$end_code"
}

md5code_get(){
FILE=$1
if [ -x "$tbox" ]; then
rawcode=`$tbox md5sum $FILE`
else
rawcode=`/system/xbin/busybox md5sum $FILE`
fi
for e in $rawcode; do
echo $e; break
done
}

mod_prop(){
NAME=$1; VARPROP=$2; FILE="$3"; [ ! "$FILE" ] && FILE=/tool_files/system.prop
if [ "$NAME" ] && [ ! "$NAME" == "=" ]; then
touch $FILE 2>/dev/null
echo "$NAME=$VARPROP" | while read prop; do export newprop=$(echo ${prop} | cut -d '=' -f1); sed -i "/${newprop}/d" $FILE; cat="`cat $FILE`"; echo $prop > $FILE; echo -n "$cat" >>$FILE; done 2>/dev/null
fi
}



del_prop(){
NAME=$1; FILE="$2"; [ ! "$FILE" ] && FILE=/tool_files/system.prop
noneprop="$NAME="
nonepropn="$noneprop\n"
if [ "$NAME" ] && [ ! "$NAME" == "=" ]; then
sed -i "/${nonepropn}/d" $FILE 2>/dev/null
sed -i "/${noneprop}/d" $FILE 2>/dev/null
fi
}


pd(){
p "$1" "$2"; echo
}

abort(){
echo "$1"; pd yellow "Process exit with error - Enter to exit"; read; exit 1
}
abortc(){
pd "$1" "$2"; pd yellow "Process exit with error - Enter to exit"; read; exit 1
}

sudo(){
CMD=$@; [ ! "$CMD" ] && CMD=sh
if [ "$(whoami)" == "root" ]; then
$CMD
else
SUBIN=`which su` || SUBIN=`which daemonsu`
[ ! "$SUBIN" ] && pd red "Root not found!" && NOSU=true
[ ! "$NOSU" ] && $SUBIN -p -c "PATH=$PATH ; $CMD"
fi
}

[ "$VMOS_SYS_NUM" ] || abortc light_red "This program is used for VMOS Pro only"

grep_prop() {
  local REGEX="s/^$1=//p"
  shift
  local FILES=$@
  [ -z "$FILES" ] && FILES='/system/build.prop'
  cat $FILES 2>/dev/null | dos2unix | sed -n "$REGEX" | head -n 1
}


main(){
my_name=`grep_prop USER_NAME /data/system/term.prop`
if [ ! "$my_name" ]; then
pd gray  "=============================================="
echo "   Hello, guy!"
echo "   My name is Husky DG"
pd gray "=============================================="
sleep 1
echo "This is the first time you open this program!"
sleep 1
echo "What should I call you? (•‿•)"
sleep 1
p none "> "
read NAME
 [ ! "$NAME" ] && NAME=HuskyDG
 mod_prop "USER_NAME" "$NAME" /data/system/term.prop 2>/dev/null
clear
my_name=`grep_prop USER_NAME /data/system/term.prop`
echo "Hi, $my_name"
sleep 1
echo "Welcome to GEEK Tools"
sleep 2
echo "Thanks for using this program!"
sleep 2
fi
clear
TOOLVER=N/A
TOOLVERCODE=0
my_name=`grep_prop USER_NAME /data/system/term.prop`
[ -f /tool_files/main/exbin/utils ] && . /tool_files/main/exbin/utils
pd gray "=============================================="
p none "   Hello, "; pd light_green "$my_name";
[ -f /tool_files/main/exbin/utils ] && pd light_green "   GeekTools INIT is installed and working" || pd light_red "   GeekTools INIT is installed but not working!"
echo "   APP: $TOOLVERAPP($TOOLVERCODEAPP) - TOOL: $TOOLVER($TOOLVERCODE)"
pd gray "=============================================="
echo "   1 - Open GeekTools"
echo "   2 - Open GeekTools (ROOT access)"
echo "   3 - Terminal Emulator"
echo "   4 - Terminal Emulator (Shizuku access)"
echo "   5 - Settings"
echo "   6 - Soft reboot"
pd red "   x - Remove GeekTool"
[ "$TOOLVERCODE" -lt "$TOOLVERCODEAPP" ] && pd purple "   @ - Update to $TOOLVERAPP"
pd orange "   0 - Close app"
p none "[CHOICE]: "
read option
if [ "$option" == "1" ]; then
    /tool_files/binary/tool
elif [ "$option" == "2" ]; then
    sudo /tool_files/binary/tool
elif [ "$option" == "3" ]; then
    cd /; clear;
    /system/bin/sh -
elif [ "$option" == "4" ]; then
    cd /; clear
    [ -f "/tool_files/binary/rish" ] || abortc red "Shizuku is not running!"
    /tool_files/binary/rish || abortc red "Shizuku is not running!"
 elif [ "$option" == "5" ]; then
clear
pd gray "=============================================="
echo " TERMINAL MODIFICATION"
pd gray "=============================================="
 echo "  1 - Change username"
 echo "  2 - Initial command"
 p none "[CHOICE]: "
 read OPT
 if [ "$OPT" == "1" ]; then
 echo "Enter your name, default is HuskyDG"
 p none "[CHOICE]: "
 read NAME
 [ ! "$NAME" ] && NAME=HuskyDG
 mod_prop "USER_NAME" "$NAME" /data/system/term.prop 2>/dev/null
 pd green "Saved configuration to /data/system/term.prop"
 elif [ "$OPT" == "2" ]; then
 echo "Type your command, it will be executed every time you open"
 echo "any Terminal app"
 p none "[CHOICE]: "
 read CMD
 mod_prop "INITIAL_CMD" "$CMD" /data/system/term.prop 2>/dev/null
 pd green "Saved configuration to /data/system/term.prop"
 fi
 read;

 
 elif [ "$option" == "6" ]; then

    setprop ctl.restart zygote
 elif [ "$option" == "x" ]; then
    clear
    if [ -f "/sbin/daemonsu" ]; then
        pd yellow "DETECT SU SBIN MODE"
        echo "GeekTool detect that you have su at \"/sbin\""
        echo "SU will not work after uninstalling GeekTool"
        echo "Before uninstalling, GeekTool will:"
        echo "  Move to \"/system/xbin\" to keep su working"
        SUPATH=/sbin/daemonsu
    elif [ -f "/tool_files/binary/daemonsu" ]; then
        pd yellow "DETECT SUHIDE MODE"
        echo "GeekTool detect that you have su not in regularly path"
        echo "Uninstall GeekTool will delete su binary"
        echo "Before uninstalling, GeekTool will:"
        echo " Move to \"/system/xbin\" to keep su working"
        SUPATH=/tool_files/binary/daemonsu
    fi
        echo "Some functions may not available after uninstalling"
echo ""
    echo "  1 - Full Uninstallation"
    echo "  2 - Restore stock boot init"
    p none "[CHOICE]: "
    read uninstall
    if [ "$uninstall" == "1" -o "$uninstall" == "2" ]; then
    clear; 
    pd gray "=============================================="
    echo "  FLASHING..."
    pd gray "=============================================="
    ( [ -f "/init.real" ] || abort "! Cannot find backup stock boot init"
if [ "$SUPATH" ]; then
echo "- Keep su binary working..."
cp $SUPATH /system_root/system/xbin/daemonsu
( cd /system_root/system/xbin
ln -s daemonsu su
ln -s daemonsu sx )
fi
echo "- Restore stock boot init..."
rm -rf /init
mv -f /init.real /init
chmod 777 /init
if [ "$uninstall" == "1" ]; then
echo "- Remove tool files..."
rm -rf /tool_files
rm -rf /sbin/tool
fi
cp /init.rc.orig /init.rc
echo "- Done!" ) 2>/dev/null
    sleep 2
    exit
    fi
    
 elif [ "$option" == "@" ]; then
    clear; 
    pd gray "=============================================="
    echo "  FLASHING..."
    pd gray "=============================================="
    echo "Now initializating..."
    echo "Flashing new boot init..."
    sh lib/libfake_tool.so
    ERR=$?;
  [ "$ERR" == "0" ] && pd light_green "Installation done!" || abortc light_red "Installation failed!"
    read
 elif [ "$option" == "0" ]; then
   exit
fi
}

main_noinit(){
clear
pd gray "=============================================="
pd light_red "   GeekTools INIT is not installed"
echo "   APP: $TOOLVERAPP($TOOLVERCODEAPP) - TOOL: N/A(0)"
pd gray "=============================================="
echo "   1 - Install GeekTools"
echo "   2 - Terminal Emulator"
echo "   3 - Soft reboot"
echo "   0 - Close app"
p none "[CHOICE]: "
read option
if [ "$option" == "1" ]; then
clear

  pd gray "=============================================="
    echo "  FLASHING..."
    pd gray "=============================================="
  echo "Now initializating..."
  echo "Flashing new boot init..."
  [ -f "lib/libfake_tool.so" ] && sh lib/libfake_tool.so || abortc light_red "Installation failed! This program might not be supported!"
  ERR=$?;
  [ "$ERR" == "0" ] && pd light_green "Installation done!" || abortc light_red "Installation failed!"
  read
elif [ "$option" == "2" ]; then
   cd /; clear;
   /system/bin/sh -
elif [ "$option" == "3" ]; then
   setprop ctl.restart zygote
elif [ "$option" == "0" ]; then
   exit
fi
}
link(){
[ ! -f "lib/$1" ] && rm -rf "lib/$1" 2>/dev/null
ln -s "$(which $1)" "lib/$1" 2>/dev/null
}


cd $priv_dir || abortc light_red "Something wrong? Please re-install the app!"
echo ". /system/etc/mkshrc
test -f ~/.shrc && . ~/.shrc
. /proc/self/fd/0 <<EOF
\$(/data/data/com.github.huskydg.vmostool/lib/libexec-t1plus.so aliases)
EOF" >etc/mkshrc
mkdir lib 2>/dev/null
link libexec-t1plus.so
link libexeo-t1plus.so
link libterm-system.so
if [ ! -f "lib/libfake_tool.so" ]; then
rm -rf "lib/libfake_tool.so" 2>/dev/null
link libfake_tool.so
fi
export PATH+=:/tool_files/main/exbin
rm -rf files/opt/*.dex 2>/dev/null
if [ ! "$huskydg" == "true" ]; then
  while true; do main_noinit; done;
else
  while true; do main; done;
fi

pd yellow "Process exit with code $? - Enter to exit"
    read; exit;