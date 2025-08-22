# Orb 备份脚本

## 描述

Orb 是一个简单的备份轮转脚本，用于备份目录并保持多个版本。

## 使用示例

### 备份

命令：`orb.sh -b /home/www /mnt/www`

这将备份 `/home/www` 到 `/mnt/www` 中。此时，在被备份的目录 `/mnt/www` 中会产生类似的目录：0、1、2、3、4 ... 8。进入这些目录后，就是每一次轮转的备份信息，数字越大表示版本越新。

### 恢复

命令：`orb.sh -r /mnt/www /home/www`

这将把 `/mnt/www/8` 恢复到 `/home/www` 中。

若要选择特定版本，例如版本 1：

`orb.sh -r /mnt/www /home/www 1`

## 感谢

感谢 [Infong](https://github.com/infong) 的奇思妙想
