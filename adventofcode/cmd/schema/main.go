// Package main will output the JSON Schema for the AdventPuzzle object.
package main

import (
	"encoding/json"
	"log/slog"
	"os"

	"github.com/invopop/jsonschema"

	aokv1alpha1 "go.jlucktay.dev/kubernetes-workbench/adventofcode/api/v1alpha1"
)

func main() {
	reflector := jsonschema.Reflector{
		ExpandedStruct: true,
	}

	if err := reflector.AddGoComments("go.jlucktay.dev/kubernetes-workbench", "adventofcode", jsonschema.WithFullComment()); err != nil {
		slog.Error("adding Go comments to reflector", slog.Any("err", err))
		os.Exit(1)
	}

	schema := reflector.Reflect(&aokv1alpha1.AdventPuzzle{})
	schema.ID = "https://github.com/jlucktay/kubernetes-workbench/blob/main/adventofcode/advent-puzzle.schema.json"

	enc := json.NewEncoder(os.Stdout)
	enc.SetIndent("", "  ")

	if err := enc.Encode(schema); err != nil {
		slog.Error("encoding schema", slog.Any("err", err))
		os.Exit(1)
	}
}
