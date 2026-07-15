# Image for the kubeops CLI, built by GoReleaser (the binary is compiled
# outside the image and copied in). Distroless: no shell, runs as nonroot,
# consistent with the workload hardening defaults of the base chart.
FROM gcr.io/distroless/static-debian12:nonroot

COPY kubeops /usr/local/bin/kubeops

USER nonroot:nonroot

ENTRYPOINT ["/usr/local/bin/kubeops"]
