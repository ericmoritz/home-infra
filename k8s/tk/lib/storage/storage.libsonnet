{
  "ds-pvc": {
    "apiVersion": "v1",
    "kind": "PersistentVolume",
    "metadata": {
        "name": "pv0003"
    },
    "spec": {
        "capacity": {
        "storage": "5Gi"
        },
        "volumeMode": "Filesystem",
        "accessModes": [
            "ReadWriteOnce"
        ],
        "persistentVolumeReclaimPolicy": "Recycle",
        "storageClassName": "slow",
        "mountOptions": [
            "hard",
            "nfsvers=4.1"
        ],
        "nfs": {
        "path": "/volume1/k8s-pv0003",
        "server": "192.168.1.2"
        }
    }
  }
}
