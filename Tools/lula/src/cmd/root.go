package cmd

import (
	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"

	"github.com/defenseunicorns/lula/src/cmd/execute"
)

var rootCmd = &cobra.Command{
	Use:   "lula",
	Short: "lula",
	Long:  `lula`,
}

func Execute() {

	commands := []*cobra.Command{
		execute.ExecuteCommand(),
		execute.GenerateCommand(),
	}

	rootCmd.AddCommand(commands...)

	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}
