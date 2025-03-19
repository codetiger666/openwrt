#!/bin/bash

Core_x86_64(){
    Author=CodeTiger
}

Core_xiaomi_ac2100(){
    Author=CodeTiger
}

Core_redmi_ax6000(){
    Author=CodeTiger
}

Diy-Part1() {
    cd $GITHUB_WORKSPACE/openwrt/package
    mkdir codetiger
    cd $GITHUB_WORKSPACE/openwrt/package/codetiger
    # 私有源
    git clone https://github.com/codetiger666/openwrt-package.git -b main --single-branch
    # 添加默认配置
    mkdir -p $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/smartdns/domain-set
    wget -O $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/smartdns/domain-set/cn https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt
    wget -O $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/smartdns/domain-set/ad https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/reject-list.txt
    /bin/cp  $GITHUB_WORKSPACE/Customize/smartdns_customer $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/smartdns/custom.conf
    # 获取kernel 指纹
    if [ "${project_device}" = "redmi_ax6000" ]; then
       curl https://downloads.openwrt.org/releases/${project_version}/targets/mediatek/filogic/openwrt-${project_version}-mediatek-filogic.manifest > kernel.manifest
       arch="openwrt-24.10/aarch64_cortex-a53"
       kmod_arch="mediatek/filogic"
    fi
    if [ "${project_device}" = "xiaomi_ac2100" ]; then
       curl https://downloads.openwrt.org/releases/${project_version}/targets/ramips/mt7621/openwrt-${project_version}-ramips-mt7621.manifest > kernel.manifest
       arch="openwrt-24.10/mipsel_24kc"
       kmod_arch="ramips/mt7621"
    fi
    kernel_finger=$(cat kernel.manifest | grep kernel | awk -F'~|-' '{print $3}')
    kernel_version=$(cat kernel.manifest | grep kernel | awk -F'~|-' '{print $2}' | sed 's/ //')
    kernel_release=$(cat kernel.manifest | grep kernel | awk -F'~|-' '{print $4}' | sed 's/r//')
    sed -i 's/${ipaddr:-"192.168.1.1"}/${ipaddr:-"10.128.1.1"}/g' $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i 's/${ipaddr:-"192.168.$((addr_offset++)).1"}/${ipaddr:-"10.128.$((addr_offset++)).1"}/g' $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i "s/timezone='UTC'/timezone='Asia\/Shanghai'/g" $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i 's/0.openwrt.pool.ntp.org/ntp.aliyun.com/g' $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i 's/1.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i '/2.openwrt.pool.ntp.org/d' $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i '/3.openwrt.pool.ntp.org/d' $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    echo "${kernel_finger}" > $GITHUB_WORKSPACE/openwrt/vermagic
    mkdir -p $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/config
    mkdir -p $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/codetiger
    mkdir -p $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/opkg/keys
    if [ "$Change_Wifi" == "true" ]; then
        cd $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/config
        /bin/cp $GITHUB_WORKSPACE/Customize/newifiD2_wireless ./wireless
    fi
    if [ "$Change_DHCP" == "true" ]; then
        cd $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/config
        /bin/cp $GITHUB_WORKSPACE/Customize/newifiD2_dhcp ./dhcp
    fi
    cd $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/config
    /bin/cp $GITHUB_WORKSPACE/Customize/nginx ./nginx
    echo "src/gz codetiger https://codetiger666.github.io/openwrt-package/$arch" >>  $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/opkg/customfeeds.conf
    echo "src/gz kmod https://downloads.openwrt.org/releases/${project_version}/targets/${kmod_arch}/kmods/${kernel_version}-${kernel_release}-${kernel_finger}" >>  $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/opkg/customfeeds.conf
    /bin/cp $GITHUB_WORKSPACE/Customize/a6a65dcebb238998 $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/opkg/keys
    # 服务监听脚本
    cd $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/codetiger
    /bin/cp $GITHUB_WORKSPACE/scripts/servicewatch ./servicewatch
    chmod +x ./servicewatch
}


Diy-Part2_xiaomi_ac2100() {
    Date=`date "+%Y%m%d%H%M"`
    mkdir release || true
    mv -f artifacts/xiaomi_ac2100/targets/ramips/mt7621/openwrt-ramips-mt7621-xiaomi_mi-router-ac2100-squashfs-sysupgrade.bin release/"openwrt-xiaomi-ac2100-${project_version}.bin"
    mv -f artifacts/xiaomi_ac2100/targets/ramips/mt7621/openwrt-ramips-mt7621-xiaomi_mi-router-ac2100-initramfs-kernel.bin release/"openwrt-xiaomi-ac2100-kernel-${project_version}.bin"
    mv -f artifacts/xiaomi_ac2100/targets/ramips/mt7621/openwrt-ramips-mt7621-xiaomi_mi-router-ac2100-squashfs-kernel1.bin release/"openwrt-xiaomi-ac2100-kernel1-${project_version}.bin"
    mv -f artifacts/xiaomi_ac2100/targets/ramips/mt7621/openwrt-ramips-mt7621-xiaomi_mi-router-ac2100-squashfs-rootfs0.bin release/"openwrt-xiaomi-ac2100-rootfs0-${project_version}.bin"
    _MD5=$(md5sum release/"xiaomi-ac2100-${project_version}.bin" | cut -d ' ' -f1)
    _MD5_kernel=$(md5sum release/"xiaomi-ac2100-kernel-${project_version}.bin" | cut -d ' ' -f1)
    _MD5_kernel1=$(md5sum release/"xiaomi-ac2100-kernel1-${project_version}.bin" | cut -d ' ' -f1)
    _MD5_rootfs0=$(md5sum release/"xiaomi-ac2100-rootfs0-${project_version}.bin" | cut -d ' ' -f1)
    _SHA256=$(sha256sum release/"xiaomi-ac2100-${project_version}.bin" | cut -d ' ' -f1)
    _SHA256_kernel=$(sha256sum release/"xiaomi-ac2100-kernel-${project_version}.bin" | cut -d ' ' -f1)
    _SHA256_kernel1=$(sha256sum release/"xiaomi-ac2100-kernel1-${project_version}.bin" | cut -d ' ' -f1)
    _SHA256_rootfs0=$(sha256sum release/"xiaomi-ac2100-rootfs0-${project_version}.bin" | cut -d ' ' -f1)
    echo -e "\nMD5:${_MD5}\nSHA256:${_SHA256}" > release/"xiaomi-ac2100-${project_version}.detail"
    echo -e "\nMD5:${_MD5_kernel}\nSHA256:${_SHA256_kernel}" > release/"xiaomi-ac2100-kernel-${project_version}.detail"
    echo -e "\nMD5:${_MD5_kernel1}\nSHA256:${_SHA256_kernel1}" > release/"xiaomi-ac2100-kernel1-${project_version}.detail"
    echo -e "\nMD5:${_MD5_rootfs0}\nSHA256:${_SHA256_rootfs0}" > release/"xiaomi-ac2100-rootfs0-${project_version}.detail"
}

Diy-Part2_redmi_ax6000() {
    Date=`date "+%Y%m%d%H%M"`
    mkdir release || true
    mv -f artifacts/redmi_ax6000/targets/mediatek/filogic/openwrt-mediatek-filogic-xiaomi_redmi-router-ax6000-ubootlayout-squashfs-sysupgrade.bin release/"openwrt-redmi-ax6000-${project_version}.bin"
    mv -f artifacts/redmi_ax6000/targets/mediatek/filogic/openwrt-mediatek-filogic-xiaomi_redmi-router-ax6000-ubootlayout-initramfs-kernel.bin release/"openwrt-redmi-ax6000-kernel-${project_version}.bin"
    _MD5=$(md5sum release/"redmi-ax6000-${project_version}.bin" | cut -d ' ' -f1)
    _MD5_kernel=$(md5sum release/"redmi-ax6000-kernel-${project_version}.bin" | cut -d ' ' -f1)
    _SHA256=$(sha256sum release/"redmi-ax6000-${project_version}.bin" | cut -d ' ' -f1)
    _SHA256_kernel=$(sha256sum release/"redmi-ax6000-kernel-${project_version}.bin" | cut -d ' ' -f1)
    echo -e "\nMD5:${_MD5}\nSHA256:${_SHA256}" > release/"redmi-ax6000-${project_version}.detail"
    echo -e "\nMD5:${_MD5_kernel}\nSHA256:${_SHA256_kernel}" > release/"redmi-ax6000-kernel-${project_version}.detail"
}

Diy-Part2_x86_64() {
    Date=`date "+%Y%m%d"`
    mkdir bin/Firmware
    mv -f bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined-efi.img.gz bin/Firmware/"openwrt-x86-64-efi-${project_version}.img.gz"
    mv -f bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined.img.gz bin/Firmware/"openwrt-x86-64-${project_version}.img.gz"
    _MD5_efi=$(md5sum bin/Firmware/"openwrt-x86-64-efi-${project_version}.img.gz" | cut -d ' ' -f1)
    _MD5=$(md5sum bin/Firmware/"openwrt-x86-64-${project_version}.img.gz" | cut -d ' ' -f1)
    _SHA256_efi=$(sha256sum bin/Firmware/"openwrt-x86-64-efi-${project_version}.img.gz" | cut -d ' ' -f1)
    _SHA256=$(sha256sum bin/Firmware/"openwrt-x86-64-${project_version}.img.gz" | cut -d ' ' -f1)
    echo -e "\nMD5:${_MD5}\nSHA256:${_SHA256}" > bin/Firmware/"openwrt-x86-64-${project_version}.detail"
    echo -e "\nMD5:${_MD5_efi}\nSHA256:${_SHA256_efi}" > bin/Firmware/"openwrt-x86-64-efi-${project_version}.detail"
}
