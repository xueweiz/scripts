#!/bin/bash
#
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# This script is for enabling/disabling kdump feature in Container Optimized OS

set -o errexit
set -o pipefail
set -u
set -x

verify_base_image() {
    mount --bind /rootfs/etc/os-release /etc/os-release
    local id="$(grep "^ID=" /etc/os-release)"
    if [[ "${id#*=}" != "cos" ]]; then
        echo "This kdump feature switch is designed to run on Container-Optimized OS only"
        exit 1
    fi
}

check_kdump_feature() {
    /usr/sbin/kdump_helper show
}

enable_kdump_feature_and_reboot_if_needed() {
    /usr/sbin/kdump_helper enable

    local is_enabled
    local is_ready
    is_enabled=$(kdump_helper show | grep "kdump enabled" | sed -rn "s/kdump enabled: (.*)/\1/p")
    is_ready=$(kdump_helper show | grep "kdump ready" | sed -rn "s/kdump ready: (.*)/\1/p")

    if [[ "${is_enabled}" == "true" && "${is_ready}" == "false" ]]; then 
        echo b > /sysrq
    fi
}

disable_kdump_feature_and_reboot_if_needed() {
    /usr/sbin/kdump_helper disable

    local is_enabled
    local is_ready
    is_enabled=$(kdump_helper show | grep "kdump enabled" | sed -rn "s/kdump enabled: (.*)/\1/p")
    is_ready=$(kdump_helper show | grep "kdump ready" | sed -rn "s/kdump ready: (.*)/\1/p")

    if [[ "${is_enabled}" == "false" && "${is_ready}" == "true" ]]; then 
        echo b > /sysrq
    fi
}

main() {
    # Do not run the installer unless the base image is Container Optimized OS (COS)
    verify_base_image

    check_kdump_feature

    case "${1}" in
        enable)
        enable_kdump_feature_and_reboot_if_needed
        ;;
        disable)
        disable_kdump_feature_and_reboot_if_needed
        ;;
        *)
        echo "Please specify whether to enable or disable kdump feature."
        ;;
    esac    
}

main "$@"
