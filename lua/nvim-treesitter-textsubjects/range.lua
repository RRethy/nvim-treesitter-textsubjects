---@class textsubjects.Position
---@field row integer
---@field col integer
local Position = {}
Position.__index = Position

---@param row integer
---@param col integer
---@return textsubjects.Position
function Position.new(row, col)
    return setmetatable({ row = row, col = col }, Position)
end

---@param pos integer[] Vim getpos() result [buf, lnum, col, off]
---@return textsubjects.Position
function Position.from_vim(pos)
    local col = pos[3]
    -- Preserve MAXCOL as a sentinel for the end of the line.
    if col ~= vim.v.maxcol then
        col = col - 1
    end
    return Position.new(pos[2] - 1, col)
end

---@return textsubjects.Position
function Position:clone()
    return Position.new(self.row, self.col)
end

---@return integer, integer
function Position:unpack()
    return self.row, self.col
end

---@param other textsubjects.Position
---@return boolean
function Position:equals(other)
    return self.row == other.row and self.col == other.col
end

---@param other textsubjects.Position
---@return boolean
function Position:lt(other)
    if self.row ~= other.row then
        return self.row < other.row
    end
    return self.col < other.col
end

---@param other textsubjects.Position
---@return boolean
function Position:le(other)
    return self:lt(other) or self:equals(other)
end

---@class textsubjects.Range
---@field start_pos textsubjects.Position
---@field end_pos textsubjects.Position
local Range = {}
Range.__index = Range

---@param pos1 textsubjects.Position
---@param pos2 textsubjects.Position
---@return textsubjects.Range
function Range.new(pos1, pos2)
    local start_pos, end_pos
    if pos2:lt(pos1) then
        start_pos, end_pos = pos2:clone(), pos1:clone()
    else
        start_pos, end_pos = pos1:clone(), pos2:clone()
    end
    return setmetatable({ start_pos = start_pos, end_pos = end_pos }, Range)
end

---@param start_node TSNode
---@param end_node TSNode
---@return textsubjects.Range
function Range.from_nodes(start_node, end_node)
    return Range.new(Position.new(start_node:start()), Position.new(end_node:end_()))
end

---@param start_node TSNode
---@param end_node TSNode
---@return textsubjects.Range
function Range.from_nodes_inner(start_node, end_node)
    return Range.new(Position.new(start_node:end_()), Position.new(end_node:start()))
end

---@return integer, integer, integer, integer
function Range:unpack()
    return self.start_pos.row, self.start_pos.col, self.end_pos.row, self.end_pos.col
end

---@return string
function Range:to_string()
    return string.format('(%d, %d) - (%d, %d)', self:unpack())
end

---@param other textsubjects.Range
---@return boolean
function Range:equals(other)
    return self.start_pos:equals(other.start_pos) and self.end_pos:equals(other.end_pos)
end

---@param other textsubjects.Range
---@return boolean
function Range:strictly_surrounds(other)
    if self:equals(other) then
        return false
    end
    return self.start_pos:le(other.start_pos) and other.end_pos:le(self.end_pos)
end

return {
    Position = Position,
    Range = Range,
}
