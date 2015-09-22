#run from app root
if ! [ -f .linux ] ; then
    echo 'chdir to scripts/linux to run this script'
    exit
fi
cd ../../;
lime build linux -Dv2 -Dlegacy -Drelease -32 &&
lime build linux -Dv2 -Dlegacy -Drelease -64;
