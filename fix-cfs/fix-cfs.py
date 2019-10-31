#/usr/bin/python2
"""Fixs a CFS bug in Container-optimized OS (COS) nodes.

The bug is described at:
https://docs.google.com/document/d/13KLD__6A935igLXpTFFomqfclATC89nAkhPOxsuKA0I/edit#

Examples:

To check script sanity in COS VM:
 sudo python fix-cfs.py --dry_run

To fix cfs bug in COS VM:
 sudo python fix-cfs.py

When running in a container/DaemonSet:
 sudo python fix-cfs.py --sys=/host/sys --dry_run
 sudo python fix-cfs.py --sys=/host/sys
 sudo python fix-cfs.py --sys=/host/sys --interval=10
"""
from __future__ import print_function
import argparse
import math
import os
import time


def _ParseCommandLine():
  parser = argparse.ArgumentParser(description='Fix cfs bug.')
  parser.add_argument('--dry_run', dest='dry_run', action='store_true',
                      help='Whether or not to run in dry_run mode')
  parser.set_defaults(dry_run=False)
  parser.add_argument('--sys', type=str, default='/sys',
                      help='The root directory of the /sys fs')
  parser.add_argument('--interval', type=int,
                      help='Seconds to wait between invocations')

  return parser.parse_args()


def ReadFile(directory, filename):
  with open(os.path.join(directory, filename), 'r') as f:
    return f.read()


def WriteFile(directory, filename, number):
  with open(os.path.join(directory, filename), 'w') as f:
    f.write('%d' % number)


def ListSubdirs(directory):
  return [
      os.path.join(directory, f)
      for f in os.listdir(directory)
      if os.path.isdir(os.path.join(directory, f))
  ]


def CalculateNewQuotaPeriodForPod(quota, period):
  scaled_times = math.ceil(
      (math.log(period) - math.log(100000)) / (math.log(147) - math.log(128)))
  new_period = 100000
  new_quota = math.floor(
      quota * math.pow(128.0 / 147, scaled_times)) + 1 + scaled_times
  return new_quota, new_period


def CalculateNewQuotaPeriodForContainer(quota, period):
  scaled_times = math.ceil(
      (math.log(period) - math.log(100000)) / (math.log(147) - math.log(128)))
  new_period = 100000
  new_quota = math.floor(quota * math.pow(128.0 / 147, scaled_times))
  new_quota = max(new_quota, 1000)
  return new_quota, new_period


def FixPodIfAffected(pod_dir, dry_run):

  try:
    quota = long(ReadFile(pod_dir, 'cpu.cfs_quota_us'))
    period = long(ReadFile(pod_dir, 'cpu.cfs_period_us'))

  except IOError:
    print('Skipping pod_dir %s. The pod may have disappeared from cfs before',
          ' it could be examined' % (pod_dir))
    return

  if quota <= 0 or period <= 0:
    return
  if period <= 100000:
    return

  print('Found a problem:')
  print('pod %s has quota %d, period %d' % (pod_dir, quota, period))
  new_quota, new_period = CalculateNewQuotaPeriodForPod(quota, period)

  if dry_run:
    print('dry_run: would fix pod %s with quota %d, period %d' %
          (pod_dir, new_quota, new_period))
    return
  try:
    WriteFile(pod_dir, 'cpu.cfs_period_us', new_period)
    WriteFile(pod_dir, 'cpu.cfs_quota_us', new_quota)
    print('fixed pod %s with quota %d, period %d' %
          (pod_dir, new_quota, new_period))
  except IOError:
    print('Warning: failed to fix cfs at pod_dir %s, ',
          'the directory may have disappeared.')
    return


def FixContainerIfAffected(container_dir, dry_run):

  try:
    quota = long(ReadFile(container_dir, 'cpu.cfs_quota_us'))
    period = long(ReadFile(container_dir, 'cpu.cfs_period_us'))

  except IOError:
    print('Skipping container_dir %s. The container may have disappeared from',
          ' cfs before it could be examined' % (container_dir))
    return

  if quota <= 0 or period <= 0:
    return
  if period <= 100000:
    return

  print('Found a problem:')
  print('container %s has quota %d, period %d' % (container_dir, quota, period))
  new_quota, new_period = CalculateNewQuotaPeriodForContainer(quota, period)

  if dry_run:
    print('dry_run: would fix container %s with quota %d, period %d' %
          (container_dir, new_quota, new_period))
    return
  try:
    WriteFile(container_dir, 'cpu.cfs_quota_us', new_quota)
    WriteFile(container_dir, 'cpu.cfs_period_us', new_period)
    print('fixed container %s with quota %d, period %d' %
          (container_dir, new_quota, new_period))
  except IOError:
    print('Warning: failed to fix cfs at container_dir %s, ',
          'the directory may have disappeared.')
    return


def FixAllPods(sysfs='/sys', dry_run=True):
  pods_dir = os.path.join(sysfs, 'fs/cgroup/cpu/kubepods/burstable')
  pod_dirs = ListSubdirs(pods_dir)
  for pod_dir in pod_dirs:
    FixPodIfAffected(pod_dir, dry_run)
    container_dirs = ListSubdirs(pod_dir)
    for container_dir in container_dirs:
      FixContainerIfAffected(container_dir, dry_run)


def main():
  args = _ParseCommandLine()
  while True:
    FixAllPods(sysfs=args.sys, dry_run=args.dry_run)
    if args.interval:
      time.sleep(args.interval)
    else:
      break


if __name__ == '__main__':
  main()
