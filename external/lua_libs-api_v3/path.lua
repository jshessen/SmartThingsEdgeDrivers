local path_mod = {}

path_mod.SEP = package.config:sub(1,1)
local WINDOWS_ABS_MATCH = "^[A-Za-z]:\\"
local WINDOWS_DEFAULT_DRIVE = "C:"

local function extract_extension(segment)
  local seg, ext = string.match(segment, "(.+)%.(.+)")
  return seg, ext
end

--- @class Path
---
--- Handle building/managing file paths
local Path = {}
path_mod.Path = Path
Path.__index = Path

--- Create a Path from a string path
---
--- @param path string The file path
--- @return Path
function Path:init(path)
  local new = {}
  if type(path) == "string" then
    new._segments = path_mod.split_path(path)
  else
    error("path must be a string ")
  end

  if path_mod.SEP == "\\" then
    new._is_windows = true
  end
  if path:match(WINDOWS_ABS_MATCH) ~= nil then
    new._is_abs = true
    new._drive = new._segments[1]
    for i = 2,#new._segments do
      new._segments[i - 1] = new._segments[i]
    end
    new._segments[#new._segments] = nil
  elseif path:sub(1,1) == path_mod.SEP then
    new._is_abs = true
  end
  if #new._segments > 0 then
    local seg, ext = extract_extension(new._segments[#new._segments])
    if seg ~= nil and ext ~= nil then
      new._segments[#new._segments] = seg
      new._ext = ext
    end
  end
  setmetatable(new, Path)
  return new
end
setmetatable(Path, {__call = Path.init})

--- Create a Path from a table of segments split on the path separator
---
--- @param segments string[] The path pieces split on the path seperator
--- @param is_abs boolean Is this an absolute path or relative path
--- @param drive string Drive name on windows
--- @return Path
function Path:from_segments(segments, is_abs, drive, ext)
  local new = {}
  new._segments = segments
  new._is_abs = is_abs
  new._ext = ext
  if path_mod.SEP == "\\" then
    new._is_windows = true
    new._drive = drive
  end
  setmetatable(new, Path)
  return new
end

--- Get a Path representing the parent of this Path
---
--- @return Path representing this_path/../
function Path:parent()
  local out = {}
  if #self._segments >= 1 then
    for i, part in ipairs(self._segments) do
      if i < #self._segments then
        out[i] = part
      elseif part == ".." then
        -- if the last segment was already an up directory, don't remove it, just add another
        out[i] = part
        out[i + 1] = ".."
      end
    end
  elseif not self._is_abs then
    out = {".."}
  else
    error("Path is root, there is no parent")
  end
  return Path:from_segments(out, self._is_abs)
end

function Path:has_extension(extension)
  return self._ext == extension
end

--- Append a new segment to the end of this Path
---
--- @param segment string the dirctory or filename to append to the end of this path
--- @return Path self, with the added segment appended
function Path:append(segment)
  if self._ext ~= nil then
    error("Cannot extend path, current path has a file extention.", 1)
  end
  local seg, ext = extract_extension(segment)
  if ext == nil then
    self._segments[#self._segments + 1] = segment
  else
    self._segments[#self._segments + 1] = seg
    self._ext = ext
  end
  return self
end

--- Find the segment index that matches the provided dir name
---
--- @param dir string a dir name to search for in this path
--- @return number|nil the position in the segment array that matches the dir, nil if not present
function Path:get_dir_pos(dir)
  for i, comp in ipairs(self._segments) do
    if comp == dir then
      return i
    end
  end
  return nil
end

--- Return a new Path representing this path only to a given directory
---
--- @param dir string a dir name to find in this path to create a new Path to
--- @return Path|nil a path the same as self, but stopping at the dir matched, nil if the dir is not present
function Path:to_dir(dir)
  local out = {}
  local found = false
  for i, comp in ipairs(self._segments) do
    out[i] = comp
    if comp == dir then
      found = true
      break
    end
  end
  if found then
    return Path:from_segments(out, self._is_abs)
  end
  return nil
end

--- Get a string representation of this path
---
--- @return string the string representation of this path
function Path:to_string()
  local prefix = ""
  if self._is_windows then
    local drive = self._drive or WINDOWS_DEFAULT_DRIVE
    prefix = self._is_abs and (drive .. path_mod.SEP) or ""
  else
    prefix = (self._is_abs and path_mod.SEP or "")
  end
  local path_str = prefix .. table.concat(self._segments, path_mod.SEP)
  if self._ext ~= nil then
    path_str = path_str .. "." .. self._ext
  end
  -- empty string path should just be the current dir
  return #path_str > 0 and path_str or "."
end

Path.__tostring = Path.to_string

--- Split a path into a segment array
---
--- @param path string a string path
--- @return string[] a segment array of the provided path
function path_mod.split_path(path)
  local path_segments = {}
  for dir in string.gmatch(path, "[^".. path_mod.SEP .. "]+") do
    path_segments[#path_segments + 1] = dir
  end
  return path_segments
end

return path_mod
