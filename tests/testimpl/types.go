package testimpl

import "github.com/launchbynttdata/lcaf-component-terratest/types"

type ThisTFModuleConfig struct {
	types.GenericTFModuleConfig
	// Shadow the base string fields with int to match the number type used in variables.
	EnvironmentNumber int `json:"environment_number"`
	ResourceNumber    int `json:"resource_number"`
}
