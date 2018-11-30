local crab = require "crab.c"
local utf8 = require "utf8.c"

local words = {}
for line in io.lines("words.txt") do
    local t = {}
    assert(utf8.toutf32(line, t), "non utf8 words detected:"..line)
    table.insert(words, t)
end

local filter = crab.open(words)
local input = io.input("texts.txt"):read("*a")
local texts = {}
assert(utf8.toutf32(input, texts), "non utf8 words detected:", texts)
filter:filter(texts)
local output = utf8.toutf8(texts)
print(output)

-- 将替换字符改成'#',过滤区间排除前后60个字
-- 另外敏感字在排除单词集中不被替换
local words = {"一定","无论遇到"}
for i,word in ipairs(words) do
    local t = {}
    assert(utf8.toutf32(word, t), "non utf8 words detected:"..word)
    words[i] = t
end
-- crab.new is alias of crab.open
local excluder = crab.new(words)
print("default replace_rune:",filter:replace_rune())
filter:replace_rune(0x23)
print("new replace_rune:",filter:replace_rune())
local texts = {}
assert(utf8.toutf32(input, texts), "non utf8 words detected:", texts)
local from = 60
local to = #texts - 60

local filter_range = {}
local start = from
local found,pos1,pos2 = excluder:next(texts,start,to)
while found do
    if pos1 > start then
        table.insert(filter_range,{start,pos1-1})
    end
    start = pos2 + 1
    found,pos1,pos2 = excluder:next(texts,start,to);
end
table.insert(filter_range,{start,to})

for i,t in ipairs(filter_range) do
    filter:filter(texts,t[1],t[2]);
end
local output = utf8.toutf8(texts)
print(output)
