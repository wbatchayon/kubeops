package unit

import (
	"bytes"
	"strings"
	"testing"

	"github.com/wbatchayon/kubeops/cmd/kubeops/commands"
)

// executeCommand runs the root command with the given args and returns the
// combined stdout/stderr output and the resulting error.
func executeCommand(t *testing.T, args ...string) (string, error) {
	t.Helper()

	cmd := commands.NewRootCommand("1.2.3", "abc1234", "2026-01-01", "test")
	buf := new(bytes.Buffer)
	cmd.SetOut(buf)
	cmd.SetErr(buf)
	cmd.SetArgs(args)

	err := cmd.Execute()
	return buf.String(), err
}

func TestRootCommand(t *testing.T) {
	tests := []struct {
		name           string
		args           []string
		wantErr        bool
		wantContains   []string
		wantNotContain []string
	}{
		{
			name:    "version subcommand prints version info",
			args:    []string{"version"},
			wantErr: false,
			wantContains: []string{
				"kubeops version 1.2.3",
				"commit: abc1234",
				"date: 2026-01-01",
				"built by: test",
			},
		},
		{
			name:    "version flag prints the same version info",
			args:    []string{"--version"},
			wantErr: false,
			wantContains: []string{
				"kubeops version 1.2.3",
				"commit: abc1234",
			},
		},
		{
			name:         "help succeeds",
			args:         []string{"--help"},
			wantErr:      false,
			wantContains: []string{"kubeops", "Available Commands"},
		},
		{
			name:         "destroy without force returns an error",
			args:         []string{"destroy"},
			wantErr:      true,
			wantContains: []string{"--force"},
		},
		{
			name:    "validate with terraform flag selects only terraform",
			args:    []string{"validate", "--terraform"},
			wantErr: false,
			wantContains: []string{
				"Validating Terraform",
				"Validation complete",
			},
			wantNotContain: []string{
				"Validating Ansible",
				"Validating Kubernetes manifests",
			},
		},
		{
			name:    "validate without flags validates everything",
			args:    []string{"validate"},
			wantErr: false,
			wantContains: []string{
				"Validating Terraform",
				"Validating Ansible",
				"Validating Kubernetes manifests",
			},
		},
		{
			name:    "validate with all flag validates everything",
			args:    []string{"validate", "--all"},
			wantErr: false,
			wantContains: []string{
				"Validating Terraform",
				"Validating Ansible",
				"Validating Kubernetes manifests",
			},
		},
		{
			name:    "unknown command fails",
			args:    []string{"bogus"},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			output, err := executeCommand(t, tt.args...)

			if tt.wantErr && err == nil {
				t.Errorf("expected an error, got nil (output: %q)", output)
			}
			if !tt.wantErr && err != nil {
				t.Errorf("unexpected error: %v (output: %q)", err, output)
			}

			for _, want := range tt.wantContains {
				if !strings.Contains(output, want) {
					t.Errorf("output missing %q\noutput: %q", want, output)
				}
			}
			for _, notWant := range tt.wantNotContain {
				if strings.Contains(output, notWant) {
					t.Errorf("output unexpectedly contains %q\noutput: %q", notWant, output)
				}
			}
		})
	}
}
