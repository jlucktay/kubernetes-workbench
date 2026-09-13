// Package solver links the operator through to the logic needed to find answers to puzzles.
package solver

import (
	"errors"

	"github.com/orsinium-labs/enum"

	aoc2016day02 "go.jlucktay.dev/adventofcode/2016/day02"

	"go.jlucktay.dev/kubernetes-workbench/adventofcode/api/v1alpha1"
)

type DayPart enum.Member[int]

var (
	One = DayPart{1}
	Two = DayPart{2}

	DayParts = enum.New(One, Two)
)

func Solve(puzzle *v1alpha1.Puzzle, dp DayPart) (string, error) {
	var result string

	if !DayParts.Contains(dp) {
		return result, errors.New("invalid DayPart")
	}

	if solverDay, ok := solvers[v1alpha1.PuzzleSpec{Year: puzzle.Spec.Year, Day: puzzle.Spec.Day}]; ok {
		switch dp {
		case One:
			_, _ = solverDay.one(puzzle.Spec.Input)
		case Two:
			_, _ = solverDay.two(puzzle.Spec.Input)
		default:
			panic("this should be unreachable")
		}
	}

	return result, nil
}

type partsSolvers struct {
	one, two func(string) (string, error)
}

var solvers = map[v1alpha1.PuzzleSpec]partsSolvers{
	{Year: 2016, Day: 2}: {one: aoc2016day02.Part1, two: aoc2016day02.Part2},
}
