#!/usr/bin/env python
import os
from random import random, randint
import mlflow
from mlflow import log_metric, log_param, log_artifacts
from mlflow.store.artifact.http_artifact_repo import HttpArtifactRepository
from pdb import set_trace as bp
if __name__ == "__main__":
    
    def http_artifact_repo():
        artifact_uri = "http://localhost/api/2.0/ofi_mlflow_artifacts/artifacts"
        return HttpArtifactRepository(artifact_uri)
    httprepo = http_artifact_repo()
    gsrepo = "gs://ofi_mlflow_artifacts/artifacts/"
    print("Log a parameter (key-value pair)")
    log_param("param1", randint(0, 100))

    print("Log a metric; metrics can be updated throughout the run")
    log_metric("foo", random())
    log_metric("foo", random() + 1)
    log_metric("foo", random() + 2)

    print("Log an artifact (output file)")
    if not os.path.exists("outputs"):
        os.makedirs("outputs")
    with open("outputs/test.txt", "w") as f:
        f.write("hello world!")
    log_artifacts("outputs")
    # , artifact_path="http://localhost/api/2.0/ofi_mlflow_artifacts/artifacts"
    # 

