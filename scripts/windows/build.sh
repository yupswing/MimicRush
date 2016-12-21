#run from app root
if ! [ -f .windows ] ; then
    echo 'chdir to scripts/windows to run this script'
    exit
fi
cd ../../;
lime build windows -Dv2 -Dlegacy -Drelease
