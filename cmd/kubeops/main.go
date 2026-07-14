package main

import (
	"fmt"
	"os"

	"github.com/spf13/viper"
	"github.com/wbatchayon/kubeops/cmd/kubeops/commands"
)

var (
	version = "0.1.0"
	commit  = "dev"
	date    = "unknown"
	builtBy = "kubeops"
)

func main() {
	// Initialize viper for configuration. The config type is inferred from
	// the file extension (e.g. kubeops.yaml); setting it explicitly would
	// make viper treat an extensionless "kubeops" file (such as the binary
	// itself) as a config file.
	viper.SetConfigName("kubeops")
	viper.AddConfigPath("$HOME/.kubeops")
	viper.AddConfigPath(".")
	viper.AutomaticEnv()

	// Register default configuration values
	viper.SetDefault("proxmox.url", "https://proxmox.example.com:8006/api2/json")
	viper.SetDefault("proxmox.node", "pve")
	viper.SetDefault("cluster.name", "kubeops")
	viper.SetDefault("cluster.kubernetes-version", "v1.28.0")
	viper.SetDefault("cluster.control-plane.replicas", 3)
	viper.SetDefault("cluster.worker.replicas", 3)
	viper.SetDefault("vault.address", "http://vault:8200")
	viper.SetDefault("argo-cd.address", "http://argocd:8080")

	// Read configuration file if present; a missing file is fine, any other
	// error (e.g. malformed YAML) is fatal
	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			fmt.Fprintf(os.Stderr, "Error reading config file: %v\n", err)
			os.Exit(1)
		}
	}

	// Execute root command
	if err := commands.NewRootCommand(version, commit, date, builtBy).Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
