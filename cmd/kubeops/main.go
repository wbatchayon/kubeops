package main

import (
	"fmt"
	"os"

	"github.com/kubeops/kubeops/cmd/kubeops/commands"
	"github.com/spf13/viper"
)

var (
	version = "0.1.0"
	commit  = "dev"
	date    = "unknown"
	builtBy = "kubeops"
)

func main() {
	// Initialize viper for configuration
	viper.SetConfigName("kubeops")
	viper.SetConfigType("yaml")
	viper.AddConfigPath("$HOME/.kubeops")
	viper.AddConfigPath(".")
	viper.AutomaticEnv()

	// Create default configuration if not exists
	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); ok {
			// Config file not found, create default
			viper.SetDefault("proxmox.url", "https://proxmox.example.com:8006/api2/json")
			viper.SetDefault("proxmox.node", "pve")
			viper.SetDefault("cluster.name", "kubeops")
			viper.SetDefault("cluster.kubernetes-version", "v1.28.0")
			viper.SetDefault("cluster.control-plane.replicas", 3)
			viper.SetDefault("cluster.worker.replicas", 3)
			viper.SetDefault("vault.address", "http://vault:8200")
			viper.SetDefault("argo-cd.address", "http://argocd:8080")
		}
	}

	// Execute root command
	if err := commands.NewRootCommand(version, commit, date, builtBy).Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
