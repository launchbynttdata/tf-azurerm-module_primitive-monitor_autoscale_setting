package testimpl

import (
	"context"
	"os"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/monitor/armmonitor"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func getAutoscaleSetting(t *testing.T, ctx types.TestContext) (armmonitor.AutoscaleSettingsClientGetResponse, string, string) {
	t.Helper()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID must be set")

	autoscaleName := terraform.Output(t, ctx.TerratestTerraformOptions(), "name")
	require.NotEmpty(t, autoscaleName, "name output must not be empty")

	resourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")
	require.NotEmpty(t, resourceGroupName, "resource_group_name output must not be empty")

	cred, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to create Azure credential")

	client, err := armmonitor.NewAutoscaleSettingsClient(subscriptionID, cred, nil)
	require.NoError(t, err, "Failed to create AutoscaleSettings client")

	setting, err := client.Get(context.Background(), resourceGroupName, autoscaleName, nil)
	require.NoError(t, err, "Failed to get autoscale setting from Azure API")

	return setting, autoscaleName, subscriptionID
}

// TestComposableComplete verifies the autoscale setting exists with the expected configuration
// and, as the write-operation exercise for this configuration-only resource, enumerates all
// autoscale settings in the resource group to confirm the setting is discoverable via list API.
func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	t.Run("TestAutoscaleSettingExists", func(t *testing.T) {
		setting, autoscaleName, _ := getAutoscaleSetting(t, ctx)

		require.NotNil(t, setting.Properties, "AutoScale setting properties must not be nil")
		assert.Equal(t, true, *setting.Properties.Enabled, "AutoScale setting must be enabled")
		assert.Equal(t, autoscaleName, *setting.Name, "AutoScale setting name should match Terraform output")
	})

	t.Run("TestAutoscaleSettingProfileConfiguration", func(t *testing.T) {
		setting, _, _ := getAutoscaleSetting(t, ctx)

		require.Equal(t, 1, len(setting.Properties.Profiles), "Exactly one profile must be configured")
		profile := setting.Properties.Profiles[0]
		assert.Equal(t, "defaultProfile", *profile.Name, "Profile name must match configured value")
		assert.Equal(t, "1", *profile.Capacity.Default, "Profile capacity default must match configured value")
		assert.Equal(t, "3", *profile.Capacity.Maximum, "Profile capacity maximum must match configured value")
		assert.Equal(t, "1", *profile.Capacity.Minimum, "Profile capacity minimum must match configured value")
		require.Equal(t, 2, len(profile.Rules), "Exactly two scaling rules must be configured")
		assert.Equal(t, "CpuPercentage", *profile.Rules[0].MetricTrigger.MetricName, "Scale-out rule metric must be CpuPercentage")
		assert.Equal(t, float64(70), *profile.Rules[0].MetricTrigger.Threshold, "Scale-out threshold must be 70")
		assert.Equal(t, "CpuPercentage", *profile.Rules[1].MetricTrigger.MetricName, "Scale-in rule metric must be CpuPercentage")
		assert.Equal(t, float64(25), *profile.Rules[1].MetricTrigger.Threshold, "Scale-in threshold must be 25")
	})

	// Write-operation exercise: enumerate all autoscale settings in the resource group
	// to confirm the resource is discoverable via the list API (exercises a different API path
	// than Get — this is the closest approximation of a "write" for a pure-configuration resource).
	t.Run("TestAutoscaleSettingListable", func(t *testing.T) {
		subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
		require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID must be set")

		autoscaleName := terraform.Output(t, ctx.TerratestTerraformOptions(), "name")
		resourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")

		cred, err := azidentity.NewDefaultAzureCredential(nil)
		require.NoError(t, err)
		client, err := armmonitor.NewAutoscaleSettingsClient(subscriptionID, cred, nil)
		require.NoError(t, err)

		pager := client.NewListByResourceGroupPager(resourceGroupName, nil)
		found := false
		for pager.More() {
			page, err := pager.NextPage(context.Background())
			require.NoError(t, err, "Failed to list autoscale settings")
			for _, s := range page.Value {
				if s.Name != nil && *s.Name == autoscaleName {
					found = true
				}
			}
		}
		assert.True(t, found, "AutoScale setting must appear in resource group listing")
	})
}

// TestComposableCompleteReadonly performs read-only verification of the autoscale setting
// using only Get (single-resource read). No list enumeration or mutation is performed.
func TestComposableCompleteReadonly(t *testing.T, ctx types.TestContext) {
	t.Run("TestAutoscaleSettingReadonly", func(t *testing.T) {
		setting, autoscaleName, _ := getAutoscaleSetting(t, ctx)

		require.NotNil(t, setting.Properties, "AutoScale setting properties must not be nil")
		assert.Equal(t, autoscaleName, *setting.Name, "AutoScale setting name should match Terraform output")
		assert.Equal(t, true, *setting.Properties.Enabled, "AutoScale setting must be enabled")
		require.Equal(t, 1, len(setting.Properties.Profiles), "Exactly one profile must be configured")
		assert.Equal(t, "defaultProfile", *setting.Properties.Profiles[0].Name, "Profile name must match configured value")
		assert.Equal(t, "1", *setting.Properties.Profiles[0].Capacity.Default, "Profile capacity default must match configured value")
	})
}
