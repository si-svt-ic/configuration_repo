## Introduction

    https://developers.redhat.com/articles/2023/11/30/how-set-and-experiment-prometheus-remote-write#prometheus_remote_write

## Setup promethues

Run the reader:

    cd prom-remote-write
    podman run -d --rm \
    --privileged \
    -p 9091:9090 \
    -v./config/reader:/etc/prometheus \
    prom/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --web.enable-remote-write-receiver


Edit file kubernetes_installation/prometheus/values-prometheus.yaml

  remote_write:
    - url: "http://192.168.30.230:9091/api/v1/write"

      write_relabel_configs:
        # drop specific metrics from remote-write
      - source_labels: ['__name__']
        regex: 'go_gc_.*'
        action: 'drop'

        # keep only specific labels for the kept metrics
      - regex: '__name__|instance|job|version|branch'
        action: 'labelkeep'

  
Update helm with new value:

  helm repo list
  helm repo show prometheus-community 
  helm list -A
  helm upgrade -n monitoring prometheus-grafana-stack -f values-prometheus.yaml kube-prometheus-stack
  helm list -A
  