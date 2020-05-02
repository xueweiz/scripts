#!/usr/bin/python3

# pip3 install --upgrade google-cloud-logging
# pip3 install --upgrade google-cloud-monitoring

import functools
import time

from google.cloud import monitoring_v3

project_id = 'xueweiz-experimental'
metric_prefix = 'agent.googleapis.com'
time_window_minutes = 5


def listMetricDescriptors(client, project, metric_prefix=''):
  metric_descriptor_filter = ''
  if metric_prefix:
    metric_descriptor_filter = 'metric.type = starts_with("%s")' % metric_prefix
  return client.list_metric_descriptors(project, metric_descriptor_filter)


def listTimeSeries(client, project, metric_type, time_window_minutes):
  now = time.time()
  interval = monitoring_v3.types.TimeInterval()
  interval.end_time.seconds = int(now)
  interval.end_time.nanos = int((now - interval.end_time.seconds) * 10**9)
  interval.start_time.seconds = int(now - time_window_minutes * 60)
  interval.start_time.nanos = interval.end_time.nanos
  return client.list_time_series(
      project, 'metric.type = "%s"' % metric_type, interval,
      monitoring_v3.enums.ListTimeSeriesRequest.TimeSeriesView.FULL)


def findReportedMetrics(client, project):
  reported_metrics = []
  for metric_descriptor in listMetricDescriptors(client, project,
                                                 metric_prefix):
    metric_type = metric_descriptor.type
    results = listTimeSeries(client, project, metric_type, time_window_minutes)
    reported = functools.reduce(
        lambda reported, result: reported or len(result.points), results, False)
    if reported:
      print(metric_type)
      reported_metrics.append(metric_type)
  return reported_metrics


def main():
  client = monitoring_v3.MetricServiceClient()
  project = client.project_path('xueweiz-experimental')
  print(findReportedMetrics(client, project))


if __name__ == '__main__':
  main()
