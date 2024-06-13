###
# @Author: zhkong
# @Date: 2023-07-25 17:07:02
 # @LastEditors: zhkong
 # @LastEditTime: 2024-03-22 22:11:33
 # @FilePath: /xiaomi-ax3600-openwrt-build/scripts/prepare.sh
###

# git clone https://github.com/zhkong/openwrt-ipq807x.git --single-branch openwrt --depth 1
git clone https://github.com/TerryLip/AX6NSS.git --single-branch openwrt --depth 1
cd openwrt

# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 添加第三方软件包
## openclash
# git clone https://github.com/vernesong/OpenClash.git --single-branch --depth 1 package/new/luci-openclash
# bash ../scripts/download-openclash-core.sh

## argon theme
git clone https://github.com/jerrykuku/luci-theme-argon.git --single-branch --depth 1 package/new/luci-theme-argon

mkdir temp
git clone https://github.com/immortalwrt/luci.git --single-branch --depth 1 temp/luci
git clone https://github.com/immortalwrt/packages.git --single-branch --depth 1 temp/packages
git clone https://github.com/immortalwrt/immortalwrt.git --single-branch --depth 1 temp/immortalwrt

## KMS激活
# mv temp/luci/applications/luci-app-vlmcsd package/new/luci-app-vlmcsd
# mv temp/packages/net/vlmcsd package/new/vlmcsd
# # edit package/new/luci-app-vlmcsd/Makefile
# sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' package/new/luci-app-vlmcsd/Makefile

rm -rf temp/luci/applications/luci-app-vlmcsd package/new/luci-app-vlmcsd
rm -rf temp/packages/net/vlmcsd package/new/vlmcsd

# AutoCore
mv temp/immortalwrt/package/emortal/autocore package/new/autocore
sed -i 's/"getTempInfo" /"getTempInfo", "getCPUBench", "getCPUUsage" /g' package/new/autocore/files/luci-mod-status-autocore.json

rm -rf feeds/luci/modules/luci-base
rm -rf feeds/luci/modules/luci-mod-status
rm -rf feeds/packages/utils/coremark
rm -rf package/emortal/default-settings

mv temp/luci/modules/luci-base feeds/luci/modules/luci-base
mv temp/luci/modules/luci-mod-status feeds/luci/modules/luci-mod-status
mv temp/packages/utils/coremark package/new/coremark
mv temp/immortalwrt/package/emortal/default-settings package/emortal/default-settings

# fix luci-theme-argon css
bash ../scripts/fix-argon-css.sh

# 增加 oh-my-zsh
# bash ../scripts/preset-terminal-tools.sh

# Modify default IP
sed -i 's/10.10.10.1/192.168.10.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 修改连接数
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# config file
cp ../config/xiaomi_ax6-stock.config .config
make defconfig

# # 编译固件
# make download -j$(nproc)
# make -j$(nproc) || make -j1 V=s
