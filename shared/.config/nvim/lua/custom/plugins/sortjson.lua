-- sortjson.nvim: sort JSON keys via commands.
-- :SortJSONByAlphaNum, :SortJSONByAlphaNumReverse,
-- :SortJSONByKeyLength, :SortJSONByKeyLengthReverse
-- Requires jq to be installed.
return {
  {
    "2nthony/sortjson.nvim",
    cmd = {
      "SortJSONByAlphaNum",
      "SortJSONByAlphaNumReverse",
      "SortJSONByKeyLength",
      "SortJSONByKeyLengthReverse",
    },
    opts = {
      jq = "jq",
      log_level = "WARN",
    },
  },
}
