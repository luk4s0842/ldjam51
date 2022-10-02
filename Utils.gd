extends Node

const SNAP_WIDTH = 32
const OFFSET = SNAP_WIDTH/2

func snapped_position(pos):
	var new_pos = Vector2(stepify(pos.x - OFFSET, SNAP_WIDTH), stepify(pos.y - OFFSET, SNAP_WIDTH))
	return new_pos + Vector2(OFFSET, OFFSET)
