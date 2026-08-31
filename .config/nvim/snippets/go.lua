local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("go", {
  s("nn", {
    t({"if err != nil {", "\t"}),
    i(0),
    t({"", "}"}),
  }),
})
