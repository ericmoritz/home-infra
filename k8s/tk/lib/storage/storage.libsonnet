{
    local k = import 'k.libsonnet',
    local pv = k.core.v1.persistentVolume,
    local pvc = k.core.v1.persistentVolumeClaim,
    local spec = pv.mixin.spec,
    local nfs = pv.mixin.spec.nfs,

    homeInfra+:: {
        nasPV(name)::
            pv.new()
            + pv.mixin.metadata.withName(name)
            + pv.mixin.metadata.withLabels({
                "name": name
            })
            + spec.withAccessModes("ReadWriteOnce")
            + spec.withCapacity({storage: "1000Gi"})
            + spec.withVolumeMode("Filesystem")
            + spec.withPersistentVolumeReclaimPolicy("Retain")
            + spec.withStorageClassName("nas")
            + spec.withMountOptions(["hard", "nfsvers=4.1"])
            + nfs.withPath("/volume1/k8s/%s" % name)
            + nfs.withServer("192.168.1.2")
        ,
        nasPVC(name)::
            pvc.new()
            + pvc.mixin.metadata.withName(name)
            + pvc.mixin.spec.withAccessModes("ReadWriteOnce")
            + pvc.mixin.spec.resources.withRequests({"storage": "1000Gi"})
            + pvc.mixin.spec.withStorageClassName("nas")
            + pvc.mixin.spec.selector.withMatchLabels({
                "name": name,
            })
        ,
        nasPVPair(name):: {
            ["%sPV" % name]: $.homeInfra.nasPV(name),
            ["%sPVC" % name]: $.homeInfra.nasPVC(name),
        }

    }
}
