package main

import (
	"encoding/json"
	"fmt"
	"math"
	"strconv"
)

func intFromInterface(value interface{}) int {
	switch v := value.(type) {
	case int:
		return v
	case int32:
		return int(v)
	case int64:
		return int(v)
	case float64:
		return int(math.Round(v))
	case float32:
		return int(math.Round(float64(v)))
	case json.Number:
		i, _ := v.Int64()
		return int(i)
	case string:
		if v == "" {
			return 0
		}
		if i, err := strconv.Atoi(v); err == nil {
			return i
		}
	}
	return 0
}

func stringFromInterface(value interface{}) string {
	switch v := value.(type) {
	case string:
		return v
	case fmt.Stringer:
		return v.String()
	case int:
		return strconv.Itoa(v)
	case int64:
		return strconv.FormatInt(v, 10)
	case float64:
		return strconv.FormatInt(int64(math.Round(v)), 10)
	}
	return ""
}
