local metadata_labels = {
  ["Document Type:"] = true,
  ["Version:"] = true,
  ["Status:"] = true,
  ["Last Reviewed:"] = true,
  ["Approved By:"] = true,
  ["Applies To:"] = true,
  ["Jurisdiction:"] = true,
}

local function starts_with_metadata_label(text)
  for label, _ in pairs(metadata_labels) do
    if text:match("^" .. label) then
      return true
    end
  end
  return false
end

function Pandoc(doc)
  local cleaned = {}
  local skipping_internal = false
  local dropping_tail = false

  for _, block in ipairs(doc.blocks) do
    local text = pandoc.utils.stringify(block)

    if dropping_tail then
      -- Drop all remaining blocks after the Change Log heading.
    elseif skipping_internal then
      if block.t == "HorizontalRule" then
        skipping_internal = false
      end
    elseif starts_with_metadata_label(text) then
      -- Drop internal document-management metadata from participant-facing DOCX files.
    elseif block.t == "Para" and text == "For AIWA Use Only" then
      skipping_internal = true
    elseif block.t == "Header" and text == "Change Log" then
      dropping_tail = true
    elseif block.t == "HorizontalRule" then
      -- Remove rules so the reference DOCX styles control spacing instead.
    else
      table.insert(cleaned, block)
    end
  end

  return pandoc.Pandoc(cleaned, doc.meta)
end
