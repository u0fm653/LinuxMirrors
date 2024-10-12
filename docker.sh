#!/bin/bash
## Author: SuperManito
## Modified: 2024-10-07
## License: MIT
## GitHub: https://github.com/SuperManito/LinuxMirrors
## Website: https://linuxmirrors.cn

## Docker CE 软件源列表
# 格式："软件源名称@软件源地址"
mirror_list_docker_ce=(
    "阿里云@mirrors.aliyun.com/docker-ce"
    "腾讯云@mirrors.tencent.com/docker-ce"
    "华为云@repo.huaweicloud.com/docker-ce"
    "微软 Azure 中国@mirror.azure.cn/docker-ce"
    "网易@mirrors.163.com/docker-ce"
    "火山引擎@mirrors.volces.com/docker"
    "清华大学@mirrors.tuna.tsinghua.edu.cn/docker-ce"
    "北京大学@mirrors.pku.edu.cn/docker-ce"
    "南京大学@mirrors.nju.edu.cn/docker-ce"
    "上海交通大学@mirror.sjtu.edu.cn/docker-ce"
    "中国科学技术大学@mirrors.ustc.edu.cn/docker-ce"
    "中国科学院软件研究所@mirror.iscas.ac.cn/docker-ce"
    "官方@download.docker.com"
)

## Docker Registry 仓库列表
# 格式："软件源名称@软件源地址"
mirror_list_registry=(
    "道客 DaoCloud@docker.m.daocloud.io"
    "AtomHub 可信镜像中心@hub.atomgit.com"
    "阿里云（杭州）@registry.cn-hangzhou.aliyuncs.com"
    "阿里云（上海）@registry.cn-shanghai.aliyuncs.com"
    "阿里云（青岛）@registry.cn-qingdao.aliyuncs.com"
    "阿里云（北京）@registry.cn-beijing.aliyuncs.com"
    "阿里云（张家口）@registry.cn-zhangjiakou.aliyuncs.com"
    "阿里云（呼和浩特）@registry.cn-huhehaote.aliyuncs.com"
    "阿里云（乌兰察布）@registry.cn-wulanchabu.aliyuncs.com"
    "阿里云（深圳）@registry.cn-shenzhen.aliyuncs.com"
    "阿里云（河源）@registry.cn-heyuan.aliyuncs.com"
    "阿里云（广州）@registry.cn-guangzhou.aliyuncs.com"
    "阿里云（成都）@registry.cn-chengdu.aliyuncs.com"
    "阿里云（香港）@registry.cn-hongkong.aliyuncs.com"
    "阿里云（日本-东京）@registry.ap-northeast-1.aliyuncs.com"
    "阿里云（新加坡）@registry.ap-southeast-1.aliyuncs.com"
    "阿里云（澳大利亚-悉尼）@registry.ap-southeast-2.aliyuncs.com"
    "阿里云（马来西亚-吉隆坡）@registry.ap-southeast-3.aliyuncs.com"
    "阿里云（印度尼西亚-雅加达）@registry.ap-southeast-5.aliyuncs.com"
    "阿里云（印度-孟买）@registry.ap-south-1.aliyuncs.com"
    "阿里云（德国-法兰克福）@registry.eu-central-1.aliyuncs.com"
    "阿里云（英国-伦敦）@registry.eu-west-1.aliyuncs.com"
    "阿里云（美国西部-硅谷）@registry.us-west-1.aliyuncs.com"
    "阿里云（美国东部-弗吉尼亚）@registry.us-east-1.aliyuncs.com"
    "阿里云（阿联酋-迪拜）@registry.me-east-1.aliyuncs.com"
    "腾讯云@mirror.ccs.tencentyun.com"
    "谷歌云@mirror.gcr.io"
    "官方 Docker Hub@registry.hub.docker.com"
)

## 定义系统判定变量
SYSTEM_DEBIAN="Debian"
SYSTEM_UBUNTU="Ubuntu"
SYSTEM_KALI="Kali"
SYSTEM_DEEPIN="Deepin"
SYSTEM_LINUX_MINT="Linuxmint"
SYSTEM_ZORIN="Zorin"
SYSTEM_REDHAT="RedHat"
SYSTEM_RHEL="Red Hat Enterprise Linux"
SYSTEM_CENTOS="CentOS"
SYSTEM_CENTOS_STREAM="CentOS Stream"
SYSTEM_ROCKY="Rocky"
SYSTEM_ALMALINUX="AlmaLinux"
SYSTEM_FEDORA="Fedora"
SYSTEM_OPENCLOUDOS="OpenCloudOS"
SYSTEM_OPENEULER="openEuler"
SYSTEM_OPENSUSE="openSUSE"
SYSTEM_ARCH="Arch"
SYSTEM_ALPINE="Alpine"

## 定义系统版本文件
File_LinuxRelease=/etc/os-release
File_RedHatRelease=/etc/redhat-release
File_DebianVersion=/etc/debian_version
File_ArmbianRelease=/etc/armbian-release
File_OpenCloudOSRelease=/etc/opencloudos-release
File_openEulerRelease=/etc/openEuler-release
File_ArchLinuxRelease=/etc/arch-release
File_AlpineRelease=/etc/alpine-release
File_ProxmoxVersion=/etc/pve/.version

## 定义软件源相关文件或目录
File_DebianSourceList=/etc/apt/sources.list
Dir_DebianExtendSource=/etc/apt/sources.list.d
Dir_YumRepos=/etc/yum.repos.d

## 定义 Docker 相关变量
DockerDir=/etc/docker
DockerConfig=$DockerDir/daemon.json
DockerConfigBackup=$DockerDir/daemon.json.bak
DockerVersionFile=docker-version.txt
DockerCEVersionFile=docker-ce-version.txt
DockerCECLIVersionFile=docker-ce-cli-version.txt

## 定义颜色变量
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[35m'
AZURE='\033[36m'
PLAIN='\033[0m'
BOLD='\033[1m'
SUCCESS="[\033[1;32m成功${PLAIN}]"
COMPLETE="[\033[1;32m完成${PLAIN}]"
WARN="[\033[1;5;33m注意${PLAIN}]"
ERROR="[\033[1;31m错误${PLAIN}]"
FAIL="[\033[1;31m失败${PLAIN}]"
TIP="[\033[1;32m提示${PLAIN}]"
WORKING="[\033[1;36m >_ ${PLAIN}]"

function main() {
    permission_judgment
    collect_system_info
    run_start
    choose_mirrors
    close_firewall_service
    install_dependency_packages
    configure_docker_ce_mirror
    install_docker_engine
    check_version
    run_end
}

## 处理命令选项
function handle_command_options() {
    ## 命令帮助
    function output_command_help() {
        echo -e "
命令选项(名称/含义/选项值)：

  --source                 指定 Docker CE 源地址                     地址
  --source-registry        指定 Docker Registry 源地址               地址
  --codename               指定 Debian 系操作系统的版本代号          代号名称
  --install-latested       控制是否安装最新版本的 Docker Engine      true 或 false
  --ignore-backup-tips     忽略覆盖备份提示                          无

问题报告 https://github.com/SuperManito/LinuxMirrors/issues
  "
    }

    ## 判断参数
    while [ $# -gt 0 ]; do
        case "$1" in
        ## 指定 Docker CE 软件源地址
        --source)
            if [ "$2" ]; then
                echo "$2" | grep -Eq "\(|\)|\[|\]|\{|\}"
                if [ $? -eq 0 ]; then
                    output_error "命令选项 ${BLUE}$2${PLAIN} 无效，请在该选项后指定有效的地址！"
                else
                    SOURCE="$(echo "$2" | sed -e 's,^http[s]\?://,,g' -e 's,/$,,')"
                    shift
                fi
            else
                output_error "命令选项 ${BLUE}$1${PLAIN} 无效，请在该选项后指定软件源地址！"
            fi
            ;;
        ## 指定 Docker Registry 仓库地址
        --source-registry)
            if [ "$2" ]; then
                echo "$2" | grep -Eq "\(|\)|\[|\]|\{|\}"
                if [ $? -eq 0 ]; then
                    output_error "命令选项 ${BLUE}$2${PLAIN} 无效，请在该选项后指定有效的地址！"
                else
                    SOURCE_REGISTRY="$(echo "$2" | sed -e 's,^http[s]\?://,,g' -e 's,/$,,')"
                    shift
                fi
            else
                output_error "命令选项 ${BLUE}$1${PLAIN} 无效，请在该选项后指定镜像仓库地址！"
            fi
            ;;
        ## 指定 Debian 版本代号
        --codename)
            if [ "$2" ]; then
                DEBIAN_CODENAME="$2"
                shift
            else
                output_error "命令选项 ${BLUE}$1${PLAIN} 无效，请在该选项后指定版本代号！"
            fi
            ;;
        ## 安装最新版本
        --install-latested)
            if [ "$2" ]; then
                case "$2" in
                [Tt]rue | [Ff]alse)
                    INSTALL_LATESTED_DOCKER="${2,,}"
                    shift
                    ;;
                *)
                    output_error "命令选项 ${BLUE}$2${PLAIN} 无效，请在该选项后指定 true 或 false ！"
                    ;;
                esac
            else
                output_error "命令选项 ${BLUE}$1${PLAIN} 无效，请在该选项后指定 true 或 false ！"
            fi
            ;;
        ## 忽略覆盖备份提示
        --ignore-backup-tips)
            IGNORE_BACKUP_TIPS="true"
            ;;
        ## 命令帮助
        --help)
            output_command_help
            exit
            ;;
        *)
            output_error "命令选项 ${BLUE}$1${PLAIN} 无效，请确认后重新输入！"
            ;;
        esac
        shift
    done
    ## 给部分命令选项赋予默认值
    IGNORE_BACKUP_TIPS="${IGNORE_BACKUP_TIPS:-"false"}"
}

function run_start() {
    [[ -z "${SOURCE}" || -z "${SOURCE_REGISTRY}" ]] && clear
    echo -e ' +-----------------------------------+'
    echo -e " | \033[0;1;35;95m⡇\033[0m  \033[0;1;33;93m⠄\033[0m \033[0;1;32;92m⣀⡀\033[0m \033[0;1;36;96m⡀\033[0;1;34;94m⢀\033[0m \033[0;1;35;95m⡀⢀\033[0m \033[0;1;31;91m⡷\033[0;1;33;93m⢾\033[0m \033[0;1;32;92m⠄\033[0m \033[0;1;36;96m⡀⣀\033[0m \033[0;1;34;94m⡀\033[0;1;35;95m⣀\033[0m \033[0;1;31;91m⢀⡀\033[0m \033[0;1;33;93m⡀\033[0;1;32;92m⣀\033[0m \033[0;1;36;96m⢀⣀\033[0m |"
    echo -e " | \033[0;1;31;91m⠧\033[0;1;33;93m⠤\033[0m \033[0;1;32;92m⠇\033[0m \033[0;1;36;96m⠇⠸\033[0m \033[0;1;34;94m⠣\033[0;1;35;95m⠼\033[0m \033[0;1;31;91m⠜⠣\033[0m \033[0;1;33;93m⠇\033[0;1;32;92m⠸\033[0m \033[0;1;36;96m⠇\033[0m \033[0;1;34;94m⠏\033[0m  \033[0;1;35;95m⠏\033[0m  \033[0;1;33;93m⠣⠜\033[0m \033[0;1;32;92m⠏\033[0m  \033[0;1;34;94m⠭⠕\033[0m |"
    echo -e ' +-----------------------------------+'
    echo -e ' 欢迎使用 Docker Engine 安装与换源脚本'
}

## 运行结束
function run_end() {
    echo -e "\n     ------ 脚本执行结束 ------"
    echo -e ' \033[0;1;35;95m┌─\033[0;1;31;91m──\033[0;1;33;93m──\033[0;1;32;92m──\033[0;1;36;96m──\033[0;1;34;94m──\033[0;1;35;95m──\033[0;1;31;91m──\033[0;1;33;93m──\033[0;1;32;92m──\033[0;1;36;96m──\033[0;1;34;94m──\033[0;1;35;95m──\033[0;1;31;91m──\033[0;1;33;93m──\033[0;1;32;92m──\033[0;1;36;96m┐\033[0m'
    echo -e ' \033[0;1;31;91m│▞\033[0;1;33;93m▀▖\033[0m            \033[0;1;32;92m▙▗\033[0;1;36;96m▌\033[0m      \033[0;1;31;91m▗\033[0;1;33;93m▐\033[0m     \033[0;1;34;94m│\033[0m'
    echo -e ' \033[0;1;33;93m│▚\033[0;1;32;92m▄\033[0m \033[0;1;36;96m▌\033[0m \033[0;1;34;94m▌▛\033[0;1;35;95m▀▖\033[0;1;31;91m▞▀\033[0;1;33;93m▖▙\033[0;1;32;92m▀▖\033[0;1;36;96m▌▘\033[0;1;34;94m▌▝\033[0;1;35;95m▀▖\033[0;1;31;91m▛▀\033[0;1;33;93m▖▄\033[0;1;32;92m▜▀\033[0m \033[0;1;36;96m▞\033[0;1;34;94m▀▖\033[0;1;35;95m│\033[0m'
    echo -e ' \033[0;1;32;92m│▖\033[0m \033[0;1;36;96m▌\033[0;1;34;94m▌\033[0m \033[0;1;35;95m▌▙\033[0;1;31;91m▄▘\033[0;1;33;93m▛▀\033[0m \033[0;1;32;92m▌\033[0m  \033[0;1;34;94m▌\033[0m \033[0;1;35;95m▌▞\033[0;1;31;91m▀▌\033[0;1;33;93m▌\033[0m \033[0;1;32;92m▌▐\033[0;1;36;96m▐\033[0m \033[0;1;34;94m▖▌\033[0m \033[0;1;35;95m▌\033[0;1;31;91m│\033[0m'
    echo -e ' \033[0;1;36;96m│▝\033[0;1;34;94m▀\033[0m \033[0;1;35;95m▝▀\033[0;1;31;91m▘▌\033[0m  \033[0;1;32;92m▝▀\033[0;1;36;96m▘▘\033[0m  \033[0;1;35;95m▘\033[0m \033[0;1;31;91m▘▝\033[0;1;33;93m▀▘\033[0;1;32;92m▘\033[0m \033[0;1;36;96m▘▀\033[0;1;34;94m▘▀\033[0m \033[0;1;35;95m▝\033[0;1;31;91m▀\033[0m \033[0;1;33;93m│\033[0m'
    echo -e ' \033[0;1;34;94m└─\033[0;1;35;95m──\033[0;1;31;91m──\033[0;1;33;93m──\033[0;1;32;92m──\033[0;1;36;96m──\033[0;1;34;94m──\033[0;1;35;95m──\033[0;1;31;91m──\033[0;1;33;93m──\033[0;1;32;92m──\033[0;1;36;96m──\033[0;1;34;94m──\033[0;1;35;95m──\033[0;1;31;91m──\033[0;1;33;93m──\033[0;1;32;92m┘\033[0m'
    echo -e "     \033[1;34mPowered by linuxmirrors.cn\033[0m\n"
}

## 报错退出
function output_error() {
    [ "$1" ] && echo -e "\n$ERROR $1\n"
    exit 1
}

## 权限判定
function permission_judgment() {
    if [ $UID -ne 0 ]; then
        output_error "权限不足，请使用 Root 用户运行本脚本"
    fi
}

## 收集系统信息
function collect_system_info() {
    ## 定义系统名称
    SYSTEM_NAME="$(cat $File_LinuxRelease | grep -E "^NAME=" | awk -F '=' '{print$2}' | sed "s/[\'\"]//g")"
    grep -q "PRETTY_NAME=" $File_LinuxRelease && SYSTEM_PRETTY_NAME="$(cat $File_LinuxRelease | grep -E "^PRETTY_NAME=" | awk -F '=' '{print$2}' | sed "s/[\'\"]//g")"
    ## 定义系统版本号
    SYSTEM_VERSION_NUMBER="$(cat $File_LinuxRelease | grep -E "^VERSION_ID=" | awk -F '=' '{print$2}' | sed "s/[\'\"]//g")"
    ## 定义系统ID
    SYSTEM_ID="$(cat $File_LinuxRelease | grep -E "^ID=" | awk -F '=' '{print$2}' | sed "s/[\'\"]//g")"
    ## 判定当前系统派系
    if [ -s $File_DebianVersion ]; then
        SYSTEM_FACTIONS="${SYSTEM_DEBIAN}"
    elif [ -s $File_openEulerRelease ]; then
        SYSTEM_FACTIONS="${SYSTEM_OPENEULER}"
    elif [ -s $File_RedHatRelease ]; then
        SYSTEM_FACTIONS="${SYSTEM_REDHAT}"
    elif [ -s $File_OpenCloudOSRelease ]; then
        SYSTEM_FACTIONS="${SYSTEM_OPENCLOUDOS}" # 注：RedHat 判断优先级需要高于 OpenCloudOS，因为官方宣称8版本基于红帽而9版本不是
    else
        output_error "无法判断当前运行环境或不支持当前操作系统！"
    fi
    ## 判定系统类型、版本、版本号
    case "${SYSTEM_FACTIONS}" in
    "${SYSTEM_DEBIAN}")
        if [ ! -x /usr/bin/lsb_release ]; then
            apt-get install -y lsb-release
            if [ $? -ne 0 ]; then
                output_error "lsb-release 软件包安装失败\n\n本脚本依赖 lsb_release 指令判断系统具体类型和版本，当前系统可能为精简安装，请自行安装后重新执行脚本！"
            fi
        fi
        SYSTEM_JUDGMENT="$(lsb_release -is)"
        SYSTEM_VERSION_CODENAME="${DEBIAN_CODENAME:-"$(lsb_release -cs)"}"
        ;;
    "${SYSTEM_REDHAT}")
        SYSTEM_JUDGMENT="$(awk '{printf $1}' $File_RedHatRelease)"
        ## 特殊系统判断
        # Red Hat Enterprise Linux
        grep -q "${SYSTEM_RHEL}" $File_RedHatRelease && SYSTEM_JUDGMENT="${SYSTEM_RHEL}"
        # CentOS Stream
        grep -q "${SYSTEM_CENTOS_STREAM}" $File_RedHatRelease && SYSTEM_JUDGMENT="${SYSTEM_CENTOS_STREAM}"
        ;;
    *)
        SYSTEM_JUDGMENT="${SYSTEM_FACTIONS}"
        ;;
    esac
    ## 判定系统处理器架构
    case "$(uname -m)" in
    x86_64)
        DEVICE_ARCH="x86_64"
        SOURCE_ARCH="amd64"
        ;;
    aarch64)
        DEVICE_ARCH="ARM64"
        SOURCE_ARCH="arm64"
        ;;
    armv7l)
        DEVICE_ARCH="ARMv7"
        SOURCE_ARCH="armhf"
        ;;
    armv6l)
        DEVICE_ARCH="ARMv6"
        SOURCE_ARCH="armhf"
        ;;
    ppc64le)
        DEVICE_ARCH="ppc64le"
        SOURCE_ARCH="ppc64le"
        ;;
    s390x)
        DEVICE_ARCH="s390x"
        SOURCE_ARCH="s390x"
        ;;
    i386 | i686)
        output_error "Docker Engine 不支持安装在 x86_32 架构的环境上！"
        ;;
    *)
        output_error "未知的系统架构：$(uname -m)"
        ;;
    esac
    ## 定义软件源分支名称
    case "${SYSTEM_FACTIONS}" in
    "${SYSTEM_DEBIAN}")
        case "${SYSTEM_JUDGMENT}" in
        "${SYSTEM_DEBIAN}")
            SOURCE_BRANCH="debian"
            ;;
        "${SYSTEM_UBUNTU}" | "${SYSTEM_ZORIN}")
            SOURCE_BRANCH="ubuntu"
            ;;
        "${SYSTEM_RHEL}")
            SOURCE_BRANCH="rhel"
            ;;
        *)
            # 部分 Debian 系衍生操作系统使用 Debian 12 的 docker ce 源
            SOURCE_BRANCH="debian"
            SYSTEM_VERSION_CODENAME="bookworm"
            ;;
        esac
        ;;
    "${SYSTEM_REDHAT}")
        case "${SYSTEM_JUDGMENT}" in
        "${SYSTEM_FEDORA}")
            SOURCE_BRANCH="fedora"
            ;;
        "${SYSTEM_RHEL}")
            SOURCE_BRANCH="rhel"
            ;;
        *)
            SOURCE_BRANCH="centos"
            ;;
        esac
        ;;
    "${SYSTEM_OPENCLOUDOS}" | "${SYSTEM_OPENEULER}")
        SOURCE_BRANCH="centos"
        ;;
    esac
    ## 定义软件源更新文字
    case "${SYSTEM_FACTIONS}" in
    "${SYSTEM_DEBIAN}")
        SYNC_MIRROR_TEXT="更新软件源"
        ;;
    "${SYSTEM_REDHAT}" | "${SYSTEM_OPENCLOUDOS}" | "${SYSTEM_OPENEULER}")
        SYNC_MIRROR_TEXT="生成软件源缓存"
        ;;
    esac
}

function choose_mirrors() {
    ## 打印软件源列表
    function print_mirrors_list() {
        local tmp_mirror_name tmp_mirror_url arr_num default_mirror_name_length tmp_mirror_name_length tmp_spaces_nums a i j
        ## 计算字符串长度
        function StringLength() {
            local text=$1
            echo "${#text}"
        }
        echo -e ''

        local list_arr=()
        local list_arr_sum="$(eval echo \${#$1[@]})"
        for ((a = 0; a < $list_arr_sum; a++)); do
            list_arr[$a]="$(eval echo \${$1[a]})"
        done
        if [ -x /usr/bin/printf ]; then
            for ((i = 0; i < ${#list_arr[@]}; i++)); do
                tmp_mirror_name=$(echo "${list_arr[i]}" | awk -F '@' '{print$1}') # 软件源名称
                # tmp_mirror_url=$(echo "${list_arr[i]}" | awk -F '@' '{print$2}') # 软件源地址
                arr_num=$((i + 1))
                default_mirror_name_length=${2:-"30"} # 默认软件源名称打印长度
                ## 补齐长度差异（中文的引号在等宽字体中占1格而非2格）
                [[ $(echo "${tmp_mirror_name}" | grep -c "“") -gt 0 ]] && let default_mirror_name_length+=$(echo "${tmp_mirror_name}" | grep -c "“")
                [[ $(echo "${tmp_mirror_name}" | grep -c "”") -gt 0 ]] && let default_mirror_name_length+=$(echo "${tmp_mirror_name}" | grep -c "”")
                [[ $(echo "${tmp_mirror_name}" | grep -c "‘") -gt 0 ]] && let default_mirror_name_length+=$(echo "${tmp_mirror_name}" | grep -c "‘")
                [[ $(echo "${tmp_mirror_name}" | grep -c "’") -gt 0 ]] && let default_mirror_name_length+=$(echo "${tmp_mirror_name}" | grep -c "’")
                # 非一般字符长度
                tmp_mirror_name_length=$(StringLength $(echo "${tmp_mirror_name}" | sed "s| ||g" | sed "s|[0-9a-zA-Z\.\=\:\_\(\)\'\"-\/\!·]||g;"))
                ## 填充空格
                tmp_spaces_nums=$(($(($default_mirror_name_length - ${tmp_mirror_name_length} - $(StringLength "${tmp_mirror_name}"))) / 2))
                for ((j = 1; j <= ${tmp_spaces_nums}; j++)); do
                    tmp_mirror_name="${tmp_mirror_name} "
                done
                printf " ❖  %-$(($default_mirror_name_length + ${tmp_mirror_name_length}))s %4s\n" "${tmp_mirror_name}" "$arr_num)"
            done
        else
            for ((i = 0; i < ${#list_arr[@]}; i++)); do
                tmp_mirror_name=$(echo "${list_arr[i]}" | awk -F '@' '{print$1}') # 软件源名称
                tmp_mirror_url=$(echo "${list_arr[i]}" | awk -F '@' '{print$2}')  # 软件源地址
                arr_num=$((i + 1))
                echo -e " ❖  $arr_num. ${tmp_mirror_url} | ${tmp_mirror_name}"
            done
        fi
    }

    function print_title() {
        local system_name="${SYSTEM_PRETTY_NAME:-"${SYSTEM_NAME} ${SYSTEM_VERSION_NUMBER}"}"
        local arch=""${DEVICE_ARCH}""
        local date="$(date "+%Y-%m-%d %H:%M:%S")"
        local timezone="$(timedatectl status 2>/dev/null | grep "Time zone" | awk -F ':' '{print$2}' | awk -F ' ' '{print$1}')"

        echo -e ''
        echo -e " 运行环境 ${BLUE}${system_name} ${arch}${PLAIN}"
        echo -e " 系统时间 ${BLUE}${date} ${timezone}${PLAIN}"
    }

    print_title
    if [[ -z "${INSTALL_LATESTED_DOCKER}" ]]; then
        ## 是否手动选择安装版本
        local CHOICE_A=$(echo -e "\n${BOLD}└─ 是否安装最新版本的 Docker Engine? [Y/n] ${PLAIN}")
        read -p "${CHOICE_A}" INPUT
        [[ -z "${INPUT}" ]] && INPUT=Y
        case $INPUT in
        [Yy] | [Yy][Ee][Ss])
            INSTALL_LATESTED_DOCKER="true"
            ;;
        [Nn] | [Nn][Oo])
            ## 安装旧版本只有官方仓库有
            INSTALL_LATESTED_DOCKER="false"
            SOURCE="download.docker.com"
            ;;
        *)
            INSTALL_LATESTED_DOCKER="true"
            echo -e "\n$WARN 输入错误，默认安装最新版本！"
            ;;
        esac
    fi

    local mirror_list_name
    if [[ -z "${SOURCE}" ]]; then
        local mirror_list_name="mirror_list_docker_ce"
        print_mirrors_list "${mirror_list_name}" 38
        local CHOICE_B=$(echo -e "\n${BOLD}└─ 请选择并输入你想使用的 Docker CE 源 [ 1-$(eval echo \${#$mirror_list_name[@]}) ]：${PLAIN}")
        while true; do
            read -p "${CHOICE_B}" INPUT
            case "${INPUT}" in
            [1-9] | [1-9][0-9] | [1-9][0-9][0-9])
                local tmp_source="$(eval echo \${${mirror_list_name}[$(($INPUT - 1))]})"
                if [[ -z "${tmp_source}" ]]; then
                    echo -e "\n$WARN 请输入有效的数字序号！"
                else
                    SOURCE="$(eval echo \${${mirror_list_name}[$(($INPUT - 1))]} | awk -F '@' '{print$2}')"
                    # echo "${SOURCE}"
                    # exit
                    break
                fi
                ;;
            *)
                echo -e "\n$WARN 请输入数字序号以选择你想使用的软件源！"
                ;;
            esac
        done
    fi

    if [[ -z "${SOURCE_REGISTRY}" ]]; then
        mirror_list_name="mirror_list_registry"
        print_mirrors_list "${mirror_list_name}" 44
        local CHOICE_C=$(echo -e "\n${BOLD}└─ 请选择并输入你想使用的 Docker Registry 源 [ 1-$(eval echo \${#$mirror_list_name[@]}) ]：${PLAIN}")
        while true; do
            read -p "${CHOICE_C}" INPUT
            case "${INPUT}" in
            [1-9] | [1-9][0-9] | [1-9][0-9][0-9])
                local tmp_source="$(eval echo \${${mirror_list_name}[$(($INPUT - 1))]})"
                if [[ -z "${tmp_source}" ]]; then
                    echo -e "\n$WARN 请输入有效的数字序号！"
                else
                    SOURCE_REGISTRY="$(eval echo \${${mirror_list_name}[$(($INPUT - 1))]} | awk -F '@' '{print$2}')"
                    # echo "${SOURCE_REGISTRY}"
                    # exit
                    break
                fi
                ;;
            *)
                echo -e "\n$WARN 请输入数字序号以选择你想使用的软件源！"
                ;;
            esac
        done
    fi
}

## 关闭防火墙和SELinux
function close_firewall_service() {
    if [ ! -x /usr/bin/systemctl ]; then
        return
    fi
    if [[ "$(systemctl is-active firewalld)" == "active" ]]; then
        if [[ -z "${CLOSE_FIREWALL}" ]]; then
            local CHOICE
            CHOICE=$(echo -e "\n${BOLD}└─ 是否关闭防火墙和 SELinux ? [Y/n] ${PLAIN}")
            read -rp "${CHOICE}" INPUT
            [[ -z "${INPUT}" ]] && INPUT=Y
            case "${INPUT}" in
            [Yy] | [Yy][Ee][Ss])
                CLOSE_FIREWALL="true"
                ;;
            [Nn] | [Nn][Oo]) ;;
            *)
                echo -e "\n$WARN 输入错误，默认不关闭！"
                ;;
            esac
        fi
        if [[ "${CLOSE_FIREWALL}" == "true" ]]; then
            local SelinuxConfig=/etc/selinux/config
            systemctl disable --now firewalld >/dev/null 2>&1
            [ -s $SelinuxConfig ] && sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" $SelinuxConfig && setenforce 0 >/dev/null 2>&1
        fi
    fi
}

## 安装环境包
function install_dependency_packages() {
    ## 删除原有源
    case "${SYSTEM_FACTIONS}" in
    "${SYSTEM_DEBIAN}")
        sed -i '/docker-ce/d' $File_DebianSourceList
        rm -rf $Dir_DebianExtendSource/docker.list
        ;;
    "${SYSTEM_REDHAT}" | "${SYSTEM_OPENCLOUDOS}" | "${SYSTEM_OPENEULER}")
        rm -rf $Dir_YumRepos/*docker*.repo
        ;;
    esac
    echo -e "\n$WORKING 开始${SYNC_MIRROR_TEXT}...\n"
    case "${SYSTEM_FACTIONS}" in
    "${SYSTEM_DEBIAN}")
        apt-get update
        ;;
    "${SYSTEM_REDHAT}" | "${SYSTEM_OPENCLOUDOS}" | "${SYSTEM_OPENEULER}")
        yum makecache
        ;;
    esac
    VERIFICATION_SOURCESYNC=$?
    if [ ${VERIFICATION_SOURCESYNC} -ne 0 ]; then
        output_error "${SYNC_MIRROR_TEXT}出错，请先确保软件包管理工具可用！"
    fi
    echo -e "\n$COMPLETE ${SYNC_MIRROR_TEXT}结束\n"
    case "${SYSTEM_FACTIONS}" in
    "${SYSTEM_DEBIAN}")
        apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
        ;;
    "${SYSTEM_REDHAT}" | "${SYSTEM_OPENEULER}" | "${SYSTEM_OPENCLOUDOS}")
        # 注：红帽 8 版本才发布了 dnf 包管理工具，为了兼容性而优先选择安装 dnf-utils
        case ${SYSTEM_VERSION_NUMBER:0:1} in
        7)
            yum install -y yum-utils device-mapper-persistent-data lvm2
            ;;
        *)
            yum install -y dnf-utils device-mapper-persistent-data lvm2
            ;;
        esac
        ;;
    esac
}

## 卸载 Docker Engine 原有版本软件包
function uninstall_original_version() {
    # 先停止并禁用 Docker 服务
    systemctl disable --now docker >/dev/null 2>&1
    sleep 2s
    # 确定需要卸载的软件包
    local package_list
    case "${SYSTEM_FACTIONS}" in
    "${SYSTEM_DEBIAN}")
        case "${SYSTEM_JUDGMENT}" in
        "${SYSTEM_UBUNTU}" | "${SYSTEM_ZORIN}")
            package_list="docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc"
            ;;
        *)
            package_list="docker.io docker-doc docker-compose podman-docker containerd runc"
            ;;
        esac
        ;;
    "${SYSTEM_REDHAT}")
        case "${SYSTEM_JUDGMENT}" in
        "${SYSTEM_FEDORA}")
            package_list="docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc"
            ;;
        "${SYSTEM_RHEL}")
            package_list="docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine"
            ;;
        *)
            package_list="docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine"
            ;;
        esac
        ;;
    "${SYSTEM_OPENCLOUDOS}" | "${SYSTEM_OPENEULER}")
        package_list="docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine"
        ;;
    esac
    # 卸载软件包并清理残留
    case "${SYSTEM_FACTIONS}" in
    "${SYSTEM_DEBIAN}")
        apt-get remove -y $package_list
        apt-get autoremove -y >/dev/null 2>&1
        ;;
    "${SYSTEM_REDHAT}" | "${SYSTEM_OPENCLOUDOS}" | "${SYSTEM_OPENEULER}")
        yum remove -y $package_list
        yum autoremove -y >/dev/null 2>&1
        ;;
    esac
}

## 配置 Docker CE 源
function configure_docker_ce_mirror() {
    case "${SYSTEM_FACTIONS}" in
    "${SYSTEM_DEBIAN}")
        ## 处理 GPG 密钥
        local file_keyring="/etc/apt/keyrings/docker.asc"
        apt-key del 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88 >/dev/null 2>&1 # 删除旧的密钥
        [ -f $file_keyring ] && rm -rf $file_keyring
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://${SOURCE}/linux/${SOURCE_BRANCH}/gpg -o $file_keyring >/dev/null
        if [ $? -ne 0 ]; then
            output_error "GPG 密钥下载失败，请检查网络或更换 Docker CE 软件源后重试！"
        fi
        chmod a+r $file_keyring
        ## 添加源
        echo "deb [arch=${SOURCE_ARCH} signed-by=${file_keyring}] https://${SOURCE}/linux/${SOURCE_BRANCH} ${SYSTEM_VERSION_CODENAME} stable" | tee $Dir_DebianExtendSource/docker.list >/dev/null 2>&1
        apt-get update
        ;;
    "${SYSTEM_REDHAT}" | "${SYSTEM_OPENCLOUDOS}" | "${SYSTEM_OPENEULER}")
        yum-config-manager -y --add-repo https://${SOURCE}/linux/${SOURCE_BRANCH}/docker-ce.repo
        sed -i "s|download.docker.com|${SOURCE}|g" $Dir_YumRepos/docker-ce.repo
        ## 兼容处理版本号
        if [[ "${SYSTEM_JUDGMENT}" != "${SYSTEM_FEDORA}" ]]; then
            local target_version
            case ${SYSTEM_VERSION_NUMBER:0:1} in
            7 | 8 | 9)
                target_version="${SYSTEM_VERSION_NUMBER:0:1}"
                ;;
            *)
                target_version="9" # 使用较新的版本
                ;;
            esac
            sed -i "s|\$releasever|${target_version}|g" $Dir_YumRepos/docker-ce.repo
            yum makecache
        fi
        ;;
    esac
}

## 安装 Docker Engine
function install_docker_engine() {
    ## 导出可安装的版本列表
    function export_version_list() {
        case "${SYSTEM_FACTIONS}" in
        "${SYSTEM_DEBIAN}")
            apt-cache madison docker-ce | awk '{print $3}' | grep -Eo "[0-9][0-9].[0-9]{1,2}.[0-9]{1,2}" >$DockerCEVersionFile
            apt-cache madison docker-ce-cli | awk '{print $3}' | grep -Eo "[0-9][0-9].[0-9]{1,2}.[0-9]{1,2}" >$DockerCECLIVersionFile
            grep -wf $DockerCEVersionFile $DockerCECLIVersionFile >$DockerVersionFile
            ;;
        "${SYSTEM_REDHAT}" | "${SYSTEM_OPENCLOUDOS}" | "${SYSTEM_OPENEULER}")
            yum list docker-ce --showduplicates | sort -r | awk '{print $2}' | grep -Eo "[0-9][0-9].[0-9]{1,2}.[0-9]{1,2}" >$DockerCEVersionFile
            yum list docker-ce-cli --showduplicates | sort -r | awk '{print $2}' | grep -Eo "[0-9][0-9].[0-9]{1,2}.[0-9]{1,2}" >$DockerCECLIVersionFile
            grep -wf $DockerCEVersionFile $DockerCECLIVersionFile >$DockerVersionFile
            ;;
        esac
        rm -rf $DockerCEVersionFile $DockerCECLIVersionFile
    }

    ## 安装
    function install_main() {
        if [[ "${INSTALL_LATESTED_DOCKER}" == "true" ]]; then
            case "${SYSTEM_FACTIONS}" in
            "${SYSTEM_DEBIAN}")
                apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            "${SYSTEM_REDHAT}" | "${SYSTEM_OPENCLOUDOS}" | "${SYSTEM_OPENEULER}")
                yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            esac
        else
            export_version_list
            echo -e "\n${GREEN} --------- 请选择你要安装的版本，如：27.1.0 ---------- ${PLAIN}\n"
            cat $DockerVersionFile
            echo -e '\n注：以上可供选择的安装版本由官方源提供，此列表以外的版本则无法安装在当前操作系统上'
            while true; do
                local CHOICE=$(echo -e "\n${BOLD}└─ 请根据上面的列表，选择并输入你想要安装的具体版本号：${PLAIN}\n")
                read -p "${CHOICE}" DOCKER_VERSION
                echo ''
                cat $DockerVersionFile | grep -Eqw "${DOCKER_VERSION}"
                if [ $? -eq 0 ]; then
                    echo "${DOCKER_VERSION}" | grep -Eqw '[0-9][0-9].[0-9]{1,2}.[0-9]{1,2}'
                    if [ $? -eq 0 ]; then
                        rm -rf $DockerVersionFile
                        break
                    else
                        echo -e "$ERROR 请输入正确的版本号！"
                    fi
                else
                    echo -e "$ERROR 输入错误请重新输入！"
                fi
            done
            case "${SYSTEM_FACTIONS}" in
            "${SYSTEM_DEBIAN}")
                check_version="$(echo ${DOCKER_VERSION} | cut -c1-2)"
                CheckSubversion="$(echo ${DOCKER_VERSION} | cut -c4-5)"
                case ${check_version} in
                18)
                    if [ ${CheckSubversion} == "09" ]; then
                        INSTALL_JUDGMENT="5:"
                    else
                        INSTALL_JUDGMENT=""
                    fi
                    ;;
                *)
                    INSTALL_JUDGMENT="5:"
                    ;;
                esac
                apt-get install -y docker-ce=${INSTALL_JUDGMENT}${DOCKER_VERSION}* docker-ce-cli=5:${DOCKER_VERSION}* containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            "${SYSTEM_REDHAT}" | "${SYSTEM_OPENCLOUDOS}" | "${SYSTEM_OPENEULER}")
                yum install -y docker-ce-${DOCKER_VERSION} docker-ce-cli-${DOCKER_VERSION} containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            esac
        fi
    }

    ## 修改 Docker Registry 镜像仓库源
    function change_docker_registry_mirror() {
        if [[ "${REGISTRY_SOURCEL}" != "registry.hub.docker.com" ]]; then
            if [ -d $DockerDir ] && [ -e $DockerConfig ]; then
                if [ -e $DockerConfigBackup ]; then
                    if [[ "${IGNORE_BACKUP_TIPS}" == "false" ]]; then
                        local CHOICE_BACKUP=$(echo -e "\n${BOLD}└─ 检测到已备份的 Docker 配置文件，是否跳过覆盖备份? [Y/n] ${PLAIN}")
                        read -p "${CHOICE_BACKUP}" INPUT
                        [[ -z "${INPUT}" ]] && INPUT=Y
                        case $INPUT in
                        [Yy] | [Yy][Ee][Ss]) ;;
                        [Nn] | [Nn][Oo])
                            echo ''
                            cp -rvf $DockerConfig $DockerConfigBackup 2>&1
                            ;;
                        *)
                            echo -e "\n$WARN 输入错误，默认不覆盖！"
                            ;;
                        esac
                    fi
                else
                    echo ''
                    cp -rvf $DockerConfig $DockerConfigBackup 2>&1
                    echo -e "\n$COMPLETE 已备份原有 Docker 配置文件至 $DockerConfigBackup"
                fi
                sleep 2s
            else
                mkdir -p $DockerDir >/dev/null 2>&1
                touch $DockerConfig
            fi
            echo -e '{\n  "registry-mirrors": ["https://SOURCE"]\n}' >$DockerConfig
            sed -i "s|SOURCE|${SOURCE_REGISTRY}|g" $DockerConfig
            systemctl daemon-reload
        fi
    }

    ## 判定是否已安装
    case "${SYSTEM_FACTIONS}" in
    "${SYSTEM_DEBIAN}")
        dpkg -l | grep docker-ce-cli -q
        ;;
    "${SYSTEM_REDHAT}" | "${SYSTEM_OPENCLOUDOS}" | "${SYSTEM_OPENEULER}")
        rpm -qa | grep docker-ce-cli -q
        ;;
    esac
    if [ $? -eq 0 ]; then
        export_version_list
        DOCKER_INSTALLED_VERSION="$(docker -v | grep -Eo "[0-9][0-9]\.[0-9]{1,2}\.[0-9]{1,2}")"
        DOCKER_VERSION_LATEST="$(cat $DockerVersionFile | head -n 1)"
        if [[ "${DOCKER_INSTALLED_VERSION}" == "${DOCKER_VERSION_LATEST}" ]]; then
            if [[ "${INSTALL_LATESTED_DOCKER}" == "true" ]]; then
                echo -e "\n$COMPLETE 检测到已安装 Docker Engine 最新版本，跳过安装"
                rm -rf $DockerVersionFile
                change_docker_registry_mirror
                if [[ $(systemctl is-active docker) == "active" ]]; then
                    systemctl restart docker
                fi
                systemctl enable --now docker >/dev/null 2>&1
                check_version
                run_end
                exit
            else
                local CHOICE=$(echo -e "\n${BOLD}└─ 检测到已安装 Docker Engine 最新版本，是否继续安装其它版本? [Y/n] ${PLAIN}")
            fi
        else
            if [[ "${INSTALL_LATESTED_DOCKER}" == "true" ]]; then
                local CHOICE=$(echo -e "\n${BOLD}└─ 检测到已安装 Docker Engine 旧版本，是否覆盖安装为最新版本? [Y/n] ${PLAIN}")
            else
                local CHOICE=$(echo -e "\n${BOLD}└─ 检测到已安装 Docker Engine 旧版本，是否继续安装其它版本? [Y/n] ${PLAIN}")
            fi
        fi
        read -p "${CHOICE}" INPUT
        [[ -z "${INPUT}" ]] && INPUT=Y
        case $INPUT in
        [Yy] | [Yy][Ee][Ss])
            echo -en "\n$WORKING 正在卸载之前的版本...\n"
            uninstall_original_version
            echo -e "\n$COMPLETE 卸载完毕\n"
            install_main
            ;;
        [Nn] | [Nn][Oo]) ;;
        *)
            echo -e "\n$WARN 输入错误，默认不覆盖安装！\n"
            ;;
        esac
        rm -rf $DockerVersionFile
    else
        uninstall_original_version
        install_main
    fi
    change_docker_registry_mirror
    systemctl stop docker >/dev/null 2>&1
    systemctl enable --now docker >/dev/null 2>&1
}

## 查看版本并验证安装结果
function check_version() {
    if [ -x /usr/bin/docker ]; then
        echo -en "\n当前安装版本："
        docker -v
        VERIFICATION_DOCKER=$?
        if [ ${VERIFICATION_DOCKER} -eq 0 ]; then
            echo -e "\n$COMPLETE 安装完成"
        else
            echo -e "\n$ERROR 安装失败"
            case "${SYSTEM_FACTIONS}" in
            "${SYSTEM_DEBIAN}")
                echo -e "\n检查源文件：cat $Dir_DebianExtendSource/docker.list"
                echo -e '请尝试手动执行安装命令： apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin\n'
                echo ''
                ;;
            "${SYSTEM_REDHAT}" | "${SYSTEM_OPENCLOUDOS}" | "${SYSTEM_OPENEULER}")
                echo -e "\n检查源文件：cat $Dir_YumRepos/docker.repo"
                echo -e '请尝试手动执行安装命令： yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin\n'
                ;;
            esac
            exit 1
        fi
        if [[ $(systemctl is-active docker) != "active" ]]; then
            sleep 2
            systemctl disable --now docker >/dev/null 2>&1
            sleep 2
            systemctl enable --now docker >/dev/null 2>&1
            sleep 2
            if [[ $(systemctl is-active docker) != "active" ]]; then
                echo -e "\n$ERROR 检测到 Docker 服务启动异常，可能由于重复安装导致"
                echo -e "\n${YELLOW} 请执行 "systemctl start docker" 或 "service docker start" 命令尝试启动，如若报错请尝试重新执行本脚本${PLAIN}"
            fi
        fi
    else
        echo -e "\n$ERROR 安装失败\n"
    fi
}

handle_command_options "$@"
main
