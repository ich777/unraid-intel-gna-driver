# Create necessary directories and clone repository
# https://storage.openvinotoolkit.org/drivers/gna/
GNA_V=1.3.5
mkdir -p /INTEL_GNA/lib/modules/${UNAME}/extra
cd ${DATA_DIR}
unzip ${DATA_DIR}/gna-drv-linux-1.3.5.zip -d ${DATA_DIR}/
PLUGIN_VERSION=$GNA_V

# Compile module and copy it over to destination
cd ${DATA_DIR}/gna-drv-mod.1.3.5/src
make -j${CPU_COUNT}
cp ${DATA_DIR}/gna-drv-mod.1.3.5/src/intel_gna.ko /INTEL_GNA/lib/modules/${UNAME}/extra

#Compress module
while read -r line
do
  xz --check=crc32 --lzma2 $line
done < <(find /INTEL_GNA/lib/modules/${UNAME}/extra -name "*.ko")

# Create Slackware Package
PLUGIN_NAME="intel_gna_driver"
BASE_DIR="/INTEL_GNA"
TMP_DIR="/tmp/${PLUGIN_NAME}_"$(echo $RANDOM)""
VERSION="$(date +'%Y.%m.%d')"
mkdir -p $TMP_DIR/$VERSION
cd $TMP_DIR/$VERSION
cp -R $BASE_DIR/* $TMP_DIR/$VERSION/
mkdir $TMP_DIR/$VERSION/install
tee $TMP_DIR/$VERSION/install/slack-desc <<EOF
       |-----handy-ruler------------------------------------------------------|
$PLUGIN_NAME: $PLUGIN_NAME Package contents:
$PLUGIN_NAME:
$PLUGIN_NAME: Source: https://storage.openvinotoolkit.org/drivers/gna/
$PLUGIN_NAME:
$PLUGIN_NAME:
$PLUGIN_NAME: Custom Intel GNA package for Unraid Kernel v${UNAME%%-*} by ich777
$PLUGIN_NAME:
EOF
${DATA_DIR}/bzroot-extracted-$UNAME/sbin/makepkg -l n -c n $TMP_DIR/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz
md5sum $TMP_DIR/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz | awk '{print $1}' > $TMP_DIR/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz.md5