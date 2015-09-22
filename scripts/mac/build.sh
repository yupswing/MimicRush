#run from app root
if [[ ! -f .mac ]] ; then
    echo 'chdir to scripts/mac to run this script'
    exit
fi
cd ../../
lime build mac -Dv2 -Dlegacy -Drelease -64
