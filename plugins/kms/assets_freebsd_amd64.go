package kms_plugin_assets

import (
	"embed"
)

// content is our static kms plugin content.
//go:embed assets/freebsd/amd64
var content embed.FS