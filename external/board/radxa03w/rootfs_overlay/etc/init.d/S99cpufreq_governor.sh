#!/bin/sh
#
# Change the cpufreq governor back to schedutil afer boot is finished
#

echo schedutil > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
