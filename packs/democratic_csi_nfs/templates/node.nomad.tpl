job "[[ .my.job_name ]]_node" {

  # you can run node plugins as service jobs as well, but this ensures
  # that all nodes in the DC have a copy.
  type = "system"

  [[ template "location" . ]]

  group "node" {

    [[ template "constraints" . ]]

    task "plugin" {
      driver = "docker"

      env {
        CSI_NODE_ID = "${attr.unique.hostname}"
      }

      config {
        image = "[[ .my.plugin_image ]]"

        args = [
          "--csi-version=[[ .my.plugin_csi_spec_version ]]",
          "--csi-name=[[ .my.plugin_id ]]",
          "--driver-config-file=${NOMAD_TASK_DIR}/driver-config-file.yaml",
          "--log-level=[[ .my.plugin_log_level ]]",
          "--csi-mode=node",
          "--server-socket=${CSI_ENDPOINT}",
        ]

        # node plugins must run as privileged jobs because they
        # mount disks to the host
        privileged   = true
        ipc_mode     = "host"
        network_mode = "host"
      }

      [[ template "plugin_config_file" . ]]

      [[ template "resources" . ]]

      csi_plugin {
        id        = "[[ .my.plugin_id ]]"
        type      = "node"
        mount_dir = "/csi"
      }

    }
  }
}
